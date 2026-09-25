import Foundation

/// Typed failures from Gardner search. A decode miss is handled, never a crash.
enum CatalogError: Error, Sendable, Equatable {
    case notFound
    case transport
    case decoding
    case cancelled
    case emptyQuery
}

enum CatalogIdentity: Sendable {
    static let userAgent = "Kollesis/1.0 (iOS; +https://kollesis-roll.pro)"
    static let searchRoot = URL(string: "https://query.wikidata.org/sparql")
        ?? URL(fileURLWithPath: "/sparql")
}

/// cgi search pl assignment remapped: query, json, page, page_size onto
/// POST Wikidata SPARQL. Never Open Food Facts. Never api.artic.edu.
@MainActor
final class CatalogClient {
    static let userAgent = CatalogIdentity.userAgent

    private let session: CatalogSession
    private let debounce: Duration
    private var inFlight: Task<[Work], Error>?

    init(session: CatalogSession, debounce: Duration = .milliseconds(500)) {
        self.session = session
        self.debounce = debounce
    }

    convenience init(urlSession: URLSession = CatalogSession.identifiedSession()) {
        self.init(
            session: CatalogSession(
                transport: .urlSession(urlSession),
                cacheURL: CatalogSession.defaultCacheURL()
            )
        )
    }

    func huntWorks(query: String) async throws -> [Work] {
        inFlight?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let session = self.session
        let delay = debounce
        let task = Task<[Work], Error> {
            if delay != .zero {
                try await Task.sleep(for: delay)
            }
            try Task.checkCancellation()
            return try await session.search(query: trimmed, page: 1, pageSize: 20)
        }
        inFlight = task
        do {
            return try await task.value
        } catch is CancellationError {
            throw CatalogError.cancelled
        }
    }

    func cancelHunt() {
        inFlight?.cancel()
        inFlight = nil
    }

    func lastResolvedWorks() async -> [Work] {
        await session.cachedWorks()
    }
}

actor CatalogSession {
    enum CatalogTransport: Sendable {
        case urlSession(URLSession)

        func send(_ request: URLRequest) async throws -> (Data, Int) {
            switch self {
            case .urlSession(let session):
                let (data, response) = try await session.data(for: request)
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                return (data, status)
            }
        }
    }

    private let transport: CatalogTransport
    private var memoryCache: [Work]
    private let cacheURL: URL?

    init(transport: CatalogTransport, cacheURL: URL? = nil) {
        self.transport = transport
        self.memoryCache = []
        self.cacheURL = cacheURL
    }

    func cachedWorks() -> [Work] {
        if !memoryCache.isEmpty { return memoryCache }
        guard let cacheURL,
              FileManager.default.fileExists(atPath: cacheURL.path),
              let data = try? Data(contentsOf: cacheURL),
              let envelope = try? CatalogDTOCodec.makeDecoder().decode(CachedWorksDTO.self, from: data)
        else { return [] }
        memoryCache = envelope.works.compactMap(\.asWork)
        return memoryCache
    }

    func search(query: String, page: Int, pageSize: Int) async throws -> [Work] {
        let request = try CatalogSession.makeRequest(query: query, page: page, pageSize: pageSize)
        let (data, status) = try await fetchWithRetry(request)
        if status == 404 {
            throw CatalogError.notFound
        }
        guard (200...299).contains(status) else {
            throw CatalogError.transport
        }
        let dto: SparqlEnvelopeDTO
        do {
            dto = try CatalogDTOCodec.makeDecoder().decode(SparqlEnvelopeDTO.self, from: data)
        } catch {
            throw CatalogError.decoding
        }
        let rows = dto.results?.bindings ?? []
        let preferred = rows.filter { !($0.image?.value ?? "").isEmpty && !($0.creatorLabel?.value ?? "").isEmpty }
        let chosen = preferred.isEmpty ? rows : preferred
        let works = chosen.compactMap { $0.asWork() }
        remember(works)
        return works
    }

    private func remember(_ works: [Work]) {
        memoryCache = works
        guard let cacheURL else { return }
        do {
            let folder = cacheURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            var excluded = URLResourceValues()
            excluded.isExcludedFromBackup = true
            var mutableFolder = folder
            try mutableFolder.setResourceValues(excluded)
            let envelope = CachedWorksDTO(works: works.map(CachedWorkDTO.init(work:)))
            let data = try CatalogDTOCodec.makeEncoder().encode(envelope)
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            memoryCache = works
        }
    }

    private func fetchWithRetry(_ request: URLRequest) async throws -> (Data, Int) {
        do {
            return try await transport.send(request)
        } catch let error as CatalogError {
            if error == .notFound { throw error }
            return try await transport.send(request)
        } catch {
            do {
                return try await transport.send(request)
            } catch {
                throw CatalogError.transport
            }
        }
    }

    static func makeRequest(query: String, page: Int, pageSize: Int) throws -> URLRequest {
        var request = URLRequest(url: CatalogIdentity.searchRoot)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue(CatalogIdentity.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/sparql-results+json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let offset = max(page - 1, 0) * pageSize
        let escaped = query.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let sparql = """
        SELECT ?item ?itemLabel ?creatorLabel ?image ?accession WHERE {
          ?item wdt:P195 wd:Q49135 .
          OPTIONAL { ?item wdt:P18 ?image . }
          OPTIONAL { ?item wdt:P170 ?creator . }
          OPTIONAL { ?item wdt:P217 ?accession . }
          ?item rdfs:label ?itemLabel .
          FILTER(LANG(?itemLabel) = "en")
          OPTIONAL {
            ?creator rdfs:label ?creatorLabel .
            FILTER(LANG(?creatorLabel) = "en")
          }
          OPTIONAL { ?item skos:altLabel ?altLabel . }
          FILTER(
            CONTAINS(LCASE(?itemLabel), LCASE("\(escaped)")) ||
            (BOUND(?creatorLabel) && CONTAINS(LCASE(?creatorLabel), LCASE("\(escaped)"))) ||
            (BOUND(?altLabel) && CONTAINS(LCASE(?altLabel), LCASE("\(escaped)")))
          )
        }
        LIMIT \(pageSize) OFFSET \(offset)
        """
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "query", value: sparql),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]
        request.httpBody = body.percentEncodedQuery?.data(using: .utf8)
        return request
    }

    static func identifiedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.httpAdditionalHeaders = ["User-Agent": CatalogIdentity.userAgent]
        return URLSession(configuration: configuration)
    }

    static func defaultCacheURL() -> URL {
        let root = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return root.appendingPathComponent("Kollesis/catalog.json", isDirectory: false)
    }
}

enum CatalogDTOCodec {
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    static func makeEncoder() -> JSONEncoder {
        JSONEncoder()
    }
}

struct SparqlEnvelopeDTO: Decodable, Sendable {
    var results: SparqlResultsDTO?
}

struct SparqlResultsDTO: Decodable, Sendable {
    var bindings: [SparqlBindingDTO]?
}

struct SparqlBindingDTO: Decodable, Sendable {
    var item: SparqlValueDTO?
    var itemLabel: SparqlValueDTO?
    var creatorLabel: SparqlValueDTO?
    var image: SparqlValueDTO?
    var accession: SparqlValueDTO?

    func asWork() -> Work? {
        let raw = item?.value ?? ""
        let objectId = raw.split(separator: "/").last.map(String.init) ?? raw
        let title = itemLabel?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let artist = creatorLabel?.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !objectId.isEmpty, !title.isEmpty else { return nil }
        return Work(
            id: UUID(),
            objectId: objectId,
            artist: artist.isEmpty ? "Unknown maker" : artist,
            title: title,
            imageURL: image?.value,
            accession: accession?.value,
            filing: .loose,
            dayKey: DayKey.from(Date())
        )
    }
}

struct SparqlValueDTO: Decodable, Sendable {
    var value: String?
}

struct CachedWorksDTO: Codable, Sendable {
    var works: [CachedWorkDTO]
}

struct CachedWorkDTO: Codable, Sendable {
    var objectId: String
    var artist: String
    var title: String
    var imageURL: String?
    var accession: String?

    init(work: Work) {
        objectId = work.objectId
        artist = work.artist
        title = work.title
        imageURL = work.imageURL
        accession = work.accession
    }

    var asWork: Work {
        Work(
            id: UUID(),
            objectId: objectId,
            artist: artist,
            title: title,
            imageURL: imageURL,
            accession: accession,
            filing: .loose,
            dayKey: DayKey.from(Date())
        )
    }
}
