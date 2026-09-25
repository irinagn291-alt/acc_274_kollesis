import XCTest
@testable import Kollesis

@MainActor
final class KollesisTests: XCTestCase {
    func test_familyInvariant_quizDrawsFromSavedWorks_andMissesStayReviewable() async throws {
        let store = try makeStore()
        store.crateWork(fixtureWork(objectId: "Q1", artist: "Johannes Vermeer", title: "The Concert"))
        store.glueRoll()
        XCTAssertEqual(store.fold, .glued)
        XCTAssertEqual(store.volumen?.workId, store.works.first?.id)
        guard let miss = store.seams.first(where: { $0.jointIndex != store.volumen?.fieldBoundary }) else {
            return XCTFail("expected a miss seam")
        }
        store.splitSeam(miss.id)
        XCTAssertEqual(store.fold, .glued)
        XCTAssertEqual(store.document.tearMarks.count, 1)
        XCTAssertTrue(store.document.tearMarks.contains { $0.seamId == miss.id })
    }

    func test_glue_samplesOnlyNotPartedThreeTokenWorks() async throws {
        let store = try makeStore()
        var parted = fixtureWork(objectId: "Z-parted", artist: "Titian Vecellio", title: "The Rape of Europa")
        parted.filing = .parted
        let kept = fixtureWork(objectId: "A-keep", artist: "John Singer Sargent", title: "El Jaleo")
        store.replaceDocument(
            RollDocument(
                schemaVersion: 1,
                works: [parted, kept],
                volumen: nil,
                seams: [],
                seamMarks: [],
                tearMarks: [],
                fold: .idle,
                cachedWorks: [],
                onboardingComplete: true,
                focusedObjectId: nil
            )
        )
        store.glueRoll()
        XCTAssertEqual(store.volumen?.workId, kept.id)
        XCTAssertFalse(store.gluePool.contains { $0.filing == .parted })
    }

    func test_glue_writesSmoothWhenRunIsShort() async throws {
        let store = try makeStore()
        store.crateWork(fixtureWork(objectId: "short", artist: "Solo", title: "One"))
        store.glueRoll()
        XCTAssertEqual(store.fold, .smooth)
        XCTAssertNil(store.volumen)
    }

    func test_split_onIdleIsRefused() async throws {
        let store = try makeStore()
        store.crateWork(fixtureWork(objectId: "idle", artist: "Two Words Here", title: "More than one"))
        store.splitSeam(UUID())
        XCTAssertEqual(store.fold, .idle)
        XCTAssertTrue(store.document.seamMarks.isEmpty)
    }

    func test_secondGlue_whileGluedIsRefused() async throws {
        let store = try makeStore()
        store.crateWork(fixtureWork(objectId: "aa", artist: "First Maker Name", title: "First picture line"))
        store.crateWork(fixtureWork(objectId: "bb", artist: "Second Maker Name", title: "Second picture line"))
        store.glueRoll()
        let first = store.volumen
        store.glueRoll()
        XCTAssertEqual(store.volumen, first)
        XCTAssertEqual(store.works.filter { $0.filing == .glued }.count, 1)
    }

    func test_trueBoundary_writesSeamMark_andFoldsParted() async throws {
        let store = try makeStore()
        store.crateWork(fixtureWork(objectId: "hit", artist: "Quiet Room Painter", title: "Dust in morning light"))
        store.glueRoll()
        guard let boundary = store.volumen?.fieldBoundary,
              let seam = store.seams.first(where: { $0.jointIndex == boundary })
        else { return XCTFail("missing boundary") }
        store.splitSeam(seam.id)
        XCTAssertEqual(store.fold, .parted)
        XCTAssertEqual(store.document.seamMarks.count, 1)
        XCTAssertEqual(store.works.first?.filing, .parted)
        XCTAssertTrue(store.gluePool.isEmpty)
    }

    func test_volumen_isArtistThenTitleXorTitleThenArtist() async throws {
        let artistFirst = fixtureWork(objectId: "even", artist: "Alpha Beta", title: "Gamma Delta")
        let titleFirst = fixtureWork(objectId: "odd", artist: "Alpha Beta", title: "Gamma Delta")
        let a = Volumen.glued(from: artistFirst)
        let b = Volumen.glued(from: titleFirst)
        XCTAssertNotEqual(a?.artistLeads, b?.artistLeads)
        XCTAssertEqual(a?.artistLeads, RollTokens.artistLeads(objectId: "even"))
        XCTAssertEqual(Set(a?.tokens.map(\.text) ?? []), Set(["Alpha", "Beta", "Gamma", "Delta"]))
        XCTAssertEqual(Set(b?.tokens.map(\.text) ?? []), Set(["Alpha", "Beta", "Gamma", "Delta"]))
    }

    func test_peelNewestMark_returnsPartedToGlued() async throws {
        let store = try makeStore()
        store.crateWork(fixtureWork(objectId: "undo", artist: "Quiet Room Painter", title: "Dust in morning light"))
        store.glueRoll()
        guard let boundary = store.volumen?.fieldBoundary,
              let hit = store.seams.first(where: { $0.jointIndex == boundary }),
              let miss = store.seams.first(where: { $0.jointIndex != boundary })
        else { return XCTFail("seams") }
        store.splitSeam(miss.id)
        store.splitSeam(hit.id)
        XCTAssertEqual(store.fold, .parted)
        store.peelNewestMark()
        XCTAssertEqual(store.fold, .glued)
        XCTAssertEqual(store.works.first?.filing, .glued)
        store.peelNewestMark()
        XCTAssertEqual(store.document.tearMarks.count, 0)
        XCTAssertEqual(store.seams.first(where: { $0.id == miss.id })?.isCooled, false)
    }

    func test_duplicateObjectId_focusesExisting() async throws {
        let store = try makeStore()
        let first = fixtureWork(objectId: "same", artist: "Maker One Name", title: "Picture one line")
        store.crateWork(first)
        store.glueRoll()
        store.crateWork(fixtureWork(objectId: "same", artist: "Other Maker", title: "Other title here"))
        XCTAssertEqual(store.works.count, 1)
        XCTAssertEqual(store.document.focusedObjectId, "same")
        XCTAssertEqual(store.fold, .glued)
    }

    func test_seededProduct_keepsALiveBoundarySeam() {
        let document = RollSeed.usedProduct()
        XCTAssertEqual(document.fold, .glued)
        XCTAssertTrue(document.onboardingComplete)
        XCTAssertNotNil(document.volumen)
        let boundary = document.volumen?.fieldBoundary
        XCTAssertTrue(document.seams.contains { !$0.isCooled && $0.jointIndex == boundary })
    }

    func test_reviewScreenKeys_mapToDifferentRoutes() {
        XCTAssertEqual(RollLinks.route(fromKey: "today"), .quiz)
        XCTAssertEqual(RollLinks.route(fromKey: "log"), .saved)
        XCTAssertEqual(RollLinks.route(fromKey: "goals"), .settings)
        XCTAssertEqual(RollLinks.route(fromKey: "explore"), .explore)
        XCTAssertEqual(
            RollLinks.route(fromArguments: ["-ReviewScreen", "log"]),
            .saved
        )
        XCTAssertEqual(RollLinks.route(from: URL(string: "kollesis://explore")!), .explore)
        XCTAssertEqual(RollLinks.route(from: URL(string: "https://kollesis-roll.pro/settings")!), .settings)
    }

    func test_persistenceRoundTrip() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let suite = "kol.test.\(UUID().uuidString)"
        let vault = RollVault(defaultsSuite: suite, directory: directory)
        let store = RollStore(vault: vault, seedSimulator: false, allowDefaultBootstrap: false)
        store.crateWork(fixtureWork(objectId: "persist", artist: "Quiet Room Painter", title: "Dust in morning light"))
        store.glueRoll()
        try await Task.sleep(for: .milliseconds(400))
        let reloaded = RollStore(vault: vault, seedSimulator: false, allowDefaultBootstrap: false)
        await reloaded.loadFromVault()
        XCTAssertEqual(reloaded.works.count, 1)
        XCTAssertEqual(reloaded.fold, .glued)
        XCTAssertNotNil(reloaded.volumen)
    }

    func test_sparqlRequest_mapsCgiFields() throws {
        let request = try CatalogSession.makeRequest(query: "vermeer", page: 2, pageSize: 10)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), CatalogIdentity.userAgent)
        let body = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
        XCTAssertTrue(body.contains("wdt:P195"))
        XCTAssertTrue(body.contains("Q49135"))
        XCTAssertTrue(body.contains("LIMIT+10") || body.contains("LIMIT%2010") || body.contains("LIMIT 10"))
        XCTAssertTrue(body.contains("OFFSET"))
    }

    private func makeStore() throws -> RollStore {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let suite = "kol.test.\(UUID().uuidString)"
        return RollStore(
            vault: RollVault(defaultsSuite: suite, directory: directory),
            seedSimulator: false,
            allowDefaultBootstrap: false
        )
    }

    private func fixtureWork(objectId: String, artist: String, title: String) -> Work {
        Work(
            id: UUID(),
            objectId: objectId,
            artist: artist,
            title: title,
            imageURL: nil,
            accession: nil,
            filing: .loose,
            dayKey: 20_260_921
        )
    }
}
