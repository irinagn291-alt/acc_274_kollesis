import Foundation

/// Closed algebraic fold for the roll: Idle | Glued | Parted, plus Smooth
/// when Glue cannot form a three-token run. A fifth case is a defect.
enum KollesisFold: String, Codable, Sendable, Equatable {
    case idle
    case glued
    case parted
    case smooth
}

/// Per-Work filing. Loose is crate-ready. Glued is on the live volumen.
/// Parted has left the glue pool.
enum WorkFiling: String, Codable, Sendable, Equatable {
    case loose
    case glued
    case parted
}

/// Day edges fold Calendar.startOfDay into Int YYYYMMDD.
enum DayKey: Sendable {
    static func from(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}

enum RollTokens {
    static func split(_ text: String) -> [String] {
        text.split { $0.isWhitespace || $0.isNewline }.map(String.init).filter { !$0.isEmpty }
    }

    static func artistLeads(objectId: String) -> Bool {
        let sum = objectId.utf8.reduce(0) { $0 &+ Int($1) }
        return sum.isMultiple(of: 2)
    }
}
