import Foundation
import SwiftUI

/// Observable fold over Works. Views call glueRoll, splitSeam, tearSeam,
/// and peelNewestMark. They never keep a second kollesis enum.
@MainActor
final class RollStore: ObservableObject {
    @Published private(set) var document: RollDocument
    @Published private(set) var decodeIssue: RollDocument.DecodeIssue
    @Published private(set) var persistFailed: Bool
    @Published var lastSeamHit: Bool
    @Published private(set) var dayKey: Int
    @Published private(set) var focusSerial = 0

    private let vault: RollVault
    private let now: () -> Date
    private let calendar: Calendar
    private let seedOnEmpty: Bool
    private var opened = false
    private var persistTask: Task<Void, Never>?
    private var persistGeneration = 0

    init(
        vault: RollVault,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current,
        seedSimulator: Bool = true,
        allowDefaultBootstrap: Bool = true
    ) {
        self.vault = vault
        self.now = now
        self.calendar = calendar
        self.seedOnEmpty = seedSimulator
        self.decodeIssue = .none
        self.persistFailed = false
        self.lastSeamHit = false
        let today = DayKey.from(now(), calendar: calendar)
        self.dayKey = today
        self.document = .empty
        if allowDefaultBootstrap || seedSimulator {
            Task { await self.loadFromVault() }
        }
    }

    var fold: KollesisFold { document.fold }
    var works: [Work] { document.works }
    var volumen: Volumen? { document.volumen }
    var seams: [Seam] { document.seams }
    var gluePool: [Work] { document.works.filter(\.canGlue) }
    var partedWorks: [Work] { document.works.filter { $0.filing == .parted } }
    var canGlue: Bool { document.fold != .glued && !gluePool.isEmpty }

    func loadFromVault() async {
        if opened { return }
        opened = true
        let loaded = await vault.load()
        if Self.hasStoredContent(loaded.0) {
            document = loaded.0
            decodeIssue = loaded.1
            return
        }
        decodeIssue = loaded.1
        await seedIfNeeded()
    }

    func glueRoll() {
        guard document.fold != .glued else { return }
        guard let work = gluePool.sorted(by: { $0.objectId < $1.objectId }).first,
              let card = Volumen.glued(from: work)
        else {
            document.fold = .smooth
            document.volumen = nil
            document.seams = []
            schedulePersist()
            return
        }
        guard let index = document.works.firstIndex(where: { $0.id == work.id }) else { return }
        document.works[index].filing = .glued
        document.volumen = card
        document.seams = Seam.hung(on: card)
        document.fold = .glued
        lastSeamHit = false
        schedulePersist()
    }

    func splitSeam(_ seamId: UUID) {
        guard document.fold == .glued,
              let card = document.volumen,
              let seam = document.seams.first(where: { $0.id == seamId }),
              !seam.isCooled
        else { return }
        if seam.jointIndex == card.fieldBoundary {
            fileSeam(seam, workId: card.workId)
        } else {
            tearSeam(seam, workId: card.workId)
        }
    }

    func tearSeam(_ seam: Seam, workId: UUID) {
        guard document.fold == .glued else { return }
        if let index = document.seams.firstIndex(where: { $0.id == seam.id }) {
            document.seams[index].isCooled = true
        }
        let stamp = now()
        document.tearMarks.append(
            TearMark(
                id: UUID(),
                workId: workId,
                seamId: seam.id,
                dayKey: DayKey.from(stamp, calendar: calendar),
                stampedAt: stamp
            )
        )
        lastSeamHit = false
        schedulePersist()
    }

    func peelNewestMark() {
        guard let mark = document.newestMark else { return }
        switch mark {
        case .seam(let filed):
            document.seamMarks.removeAll { $0.id == filed.id }
            if let index = document.works.firstIndex(where: { $0.id == filed.workId }) {
                document.works[index].filing = .glued
            }
            document.fold = .glued
        case .tear(let tear):
            document.tearMarks.removeAll { $0.id == tear.id }
            if let index = document.seams.firstIndex(where: { $0.id == tear.seamId }) {
                document.seams[index].isCooled = false
            }
        }
        lastSeamHit = false
        schedulePersist(immediate: true)
    }

    @discardableResult
    func crateWork(_ incoming: Work) -> Bool {
        if let existing = document.works.first(where: { $0.objectId == incoming.objectId }) {
            document.focusedObjectId = existing.objectId
            focusSerial += 1
            schedulePersist()
            return false
        }
        var work = incoming
        work.filing = .loose
        work.dayKey = DayKey.from(now(), calendar: calendar)
        document.works.append(work)
        document.focusedObjectId = work.objectId
        if document.fold == .smooth {
            document.fold = .idle
        }
        schedulePersist()
        return true
    }

    func rememberCatalog(_ works: [Work]) {
        document.cachedWorks = works
        schedulePersist()
    }

    func resetAllData() {
        persistGeneration += 1
        persistTask?.cancel()
        persistTask = nil
        document = .empty
        decodeIssue = .none
        persistFailed = false
        lastSeamHit = false
        let generation = persistGeneration
        Task { [vault] in
            do {
                try await vault.wipe()
            } catch {
                if generation == persistGeneration {
                    decodeIssue = .startedEmpty
                }
            }
        }
    }

    func retryPersist() {
        schedulePersist(immediate: true)
    }

    func noteDayEdge() {
        let next = DayKey.from(now(), calendar: calendar)
        if next != dayKey {
            dayKey = next
        }
    }

    func flushForScenePhase(_ phase: ScenePhase) {
        if phase == .inactive || phase == .background {
            schedulePersist(immediate: true)
        }
        if phase == .active {
            noteDayEdge()
        }
    }

    func replaceDocument(_ next: RollDocument) {
        document = next
    }

    func markOnboardingComplete() {
        document.onboardingComplete = true
        schedulePersist()
    }

    func reopenOnboarding() {
        document.onboardingComplete = false
        schedulePersist()
    }

    private func fileSeam(_ seam: Seam, workId: UUID) {
        let stamp = now()
        document.seamMarks.append(
            SeamMark(
                id: UUID(),
                workId: workId,
                seamId: seam.id,
                dayKey: DayKey.from(stamp, calendar: calendar),
                stampedAt: stamp
            )
        )
        if let index = document.works.firstIndex(where: { $0.id == workId }) {
            document.works[index].filing = .parted
        }
        document.fold = .parted
        lastSeamHit = true
        schedulePersist(immediate: true)
    }

    private func schedulePersist(immediate: Bool = false) {
        persistGeneration += 1
        persistTask?.cancel()
        let snapshot = document
        let generation = persistGeneration
        persistTask = Task { [vault] in
            if !immediate {
                try? await Task.sleep(for: .milliseconds(280))
            }
            guard !Task.isCancelled, generation == persistGeneration else { return }
            do {
                try await vault.persist(snapshot)
                await MainActor.run {
                    if generation == persistGeneration {
                        persistFailed = false
                    }
                }
            } catch {
                await MainActor.run {
                    if generation == persistGeneration {
                        persistFailed = true
                    }
                }
            }
        }
    }

    private static func hasStoredContent(_ document: RollDocument) -> Bool {
        !document.works.isEmpty
            || document.volumen != nil
            || document.onboardingComplete
            || !document.seamMarks.isEmpty
            || !document.tearMarks.isEmpty
    }

    private func seedIfNeeded() async {
        guard seedOnEmpty else { return }
        #if targetEnvironment(simulator)
        if await vault.isDemoSeeded() { return }
        document = RollSeed.usedProduct()
        await vault.markDemoSeeded()
        try? await vault.persist(document)
        #endif
    }
}

enum RollSeed {
    static func usedProduct(now: Date = Date(), calendar: Calendar = .current) -> RollDocument {
        let day = DayKey.from(now, calendar: calendar)
        var works = GardnerShelf.seedWorks()
        if works.count >= 4 {
            works[2].filing = .parted
            works[3].filing = .parted
        }
        let live = works.first(where: { $0.canGlue }) ?? works[0]
        if let index = works.firstIndex(where: { $0.id == live.id }) {
            works[index].filing = .glued
        }
        let volumen = Volumen.glued(from: live)
        let seams = volumen.map(Seam.hung) ?? []
        var seamMarks: [SeamMark] = []
        var tearMarks: [TearMark] = []
        if let firstParted = works.first(where: { $0.filing == .parted }) {
            seamMarks.append(
                SeamMark(
                    id: UUID(),
                    workId: firstParted.id,
                    seamId: UUID(),
                    dayKey: day,
                    stampedAt: now.addingTimeInterval(-3600)
                )
            )
        }
        if let second = works.dropFirst().first(where: { $0.filing == .parted }) {
            seamMarks.append(
                SeamMark(
                    id: UUID(),
                    workId: second.id,
                    seamId: UUID(),
                    dayKey: day,
                    stampedAt: now.addingTimeInterval(-1800)
                )
            )
        }
        var cooledSeams = seams
        if let seam = cooledSeams.first {
            cooledSeams[0].isCooled = true
            tearMarks.append(
                TearMark(
                    id: UUID(),
                    workId: live.id,
                    seamId: seam.id,
                    dayKey: day,
                    stampedAt: now.addingTimeInterval(-90)
                )
            )
        }
        return RollDocument(
            schemaVersion: 1,
            works: works,
            volumen: volumen,
            seams: cooledSeams,
            seamMarks: seamMarks,
            tearMarks: tearMarks,
            fold: .glued,
            cachedWorks: GardnerShelf.seedWorks(),
            onboardingComplete: true,
            focusedObjectId: live.objectId
        )
    }
}
