import Foundation

/// Codable projection of the roll. Kollesis case is stored; parted-ness is
/// not a parallel bool.
struct RollDocument: Codable, Sendable, Equatable {
    var schemaVersion: Int
    var works: [Work]
    var volumen: Volumen?
    var seams: [Seam]
    var seamMarks: [SeamMark]
    var tearMarks: [TearMark]
    var fold: KollesisFold
    var cachedWorks: [Work]
    var onboardingComplete: Bool
    var focusedObjectId: String?

    static let defaultsKey = "kol.roll.v1"
    static let backupKey = "kol.roll.v1.backup"
    static let demoKey = "kol.demo.v1"

    static let empty = RollDocument(
        schemaVersion: 1,
        works: [],
        volumen: nil,
        seams: [],
        seamMarks: [],
        tearMarks: [],
        fold: .idle,
        cachedWorks: [],
        onboardingComplete: false,
        focusedObjectId: nil
    )

    var newestMark: RollMark? {
        let seams = seamMarks.map(RollMark.seam)
        let tears = tearMarks.map(RollMark.tear)
        return (seams + tears).max(by: { $0.stampedAt < $1.stampedAt })
    }

    enum DecodeIssue: Sendable, Equatable {
        case none
        case recoveredFromBackup
        case startedEmpty
    }
}

enum RollDocumentCodec {
    static func encode(_ document: RollDocument) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(document)
    }

    static func decode(_ data: Data) throws -> RollDocument {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        let document = try decoder.decode(RollDocument.self, from: data)
        guard document.schemaVersion >= 1 else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "unsupported schema")
            )
        }
        return document
    }
}
