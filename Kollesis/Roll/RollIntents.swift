import AppIntents

/// Opens Quiz, Explore, Saved, or Settings, or fires glueRoll / splitSeam in place.
struct OpenQuizIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Quiz"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await RollGate.handle(.quiz)
        return .result()
    }
}

struct OpenExploreIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Explore"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await RollGate.handle(.explore)
        return .result()
    }
}

struct OpenSavedIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Saved"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await RollGate.handle(.saved)
        return .result()
    }
}

struct OpenSettingsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Settings"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await RollGate.handle(.settings)
        return .result()
    }
}

struct GlueRollIntent: AppIntent {
    static let title: LocalizedStringResource = "Glue the roll"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await RollGate.handle(.glue)
        return .result()
    }
}

struct SplitSeamIntent: AppIntent {
    static let title: LocalizedStringResource = "Split the seam"
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await RollGate.handle(.split)
        return .result()
    }
}

struct RollTicket: Equatable {
    let id = UUID()
    let route: RollRoute
}

/// App-owned router. Intents call handle. The view reads tickets and does not write the gate.
@MainActor
final class RollRouter: ObservableObject {
    static let shared = RollRouter()

    private weak var store: RollStore?
    @Published private(set) var ticket: RollTicket?

    func attach(_ store: RollStore) {
        self.store = store
    }

    func handle(_ route: RollRoute) {
        switch route {
        case .glue:
            store?.glueRoll()
            ticket = RollTicket(route: .quiz)
        case .split:
            if let seam = store?.seams.first(where: { !$0.isCooled }) {
                store?.splitSeam(seam.id)
            }
            ticket = RollTicket(route: .quiz)
        default:
            ticket = RollTicket(route: route)
        }
    }
}

@MainActor
enum RollGate {
    static func handle(_ route: RollRoute) {
        RollRouter.shared.handle(route)
    }
}
