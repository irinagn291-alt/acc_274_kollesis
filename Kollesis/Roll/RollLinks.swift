import Foundation

/// Launch and URL routes into Quiz, Explore, Saved, Settings, or an in-place Glue.
/// `-ReviewScreen today|log|goals|explore` are keys, not tabs.
enum RollRoute: String, Sendable, Equatable {
    case quiz
    case explore
    case saved
    case settings
    case glue
    case split
}

enum RollLinks {
    static func route(fromArguments arguments: [String]) -> RollRoute? {
        guard let flag = arguments.firstIndex(of: "-ReviewScreen"),
              arguments.indices.contains(flag + 1)
        else { return nil }
        return route(fromKey: arguments[flag + 1])
    }

    static func route(fromKey key: String) -> RollRoute? {
        switch key {
        case "today": .quiz
        case "log": .saved
        case "goals": .settings
        case "explore": .explore
        default: nil
        }
    }

    static func route(from url: URL) -> RollRoute? {
        let host = url.host?.lowercased() ?? ""
        let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let token = path.isEmpty ? host : path
        switch token {
        case "quiz": return .quiz
        case "explore": return .explore
        case "saved": return .saved
        case "settings": return .settings
        case "glue": return .glue
        case "split": return .split
        default: return nil
        }
    }
}

enum RollSheet: String, Identifiable {
    case explore
    case saved
    case settings

    var id: String { rawValue }
}
