import Foundation

/// A cooled miss. Written when the tapped Seam is not the field boundary.
/// The Volumen stays glued.
struct TearMark: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var workId: UUID
    var seamId: UUID
    var dayKey: Int
    var stampedAt: Date
}

enum RollMark: Sendable, Equatable {
    case seam(SeamMark)
    case tear(TearMark)

    var stampedAt: Date {
        switch self {
        case .seam(let mark): mark.stampedAt
        case .tear(let mark): mark.stampedAt
        }
    }
}
