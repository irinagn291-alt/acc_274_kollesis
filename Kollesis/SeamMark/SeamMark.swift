import Foundation

/// A filed cataloguing break. Written when the tapped Seam is the true field boundary.
struct SeamMark: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var workId: UUID
    var seamId: UUID
    var dayKey: Int
    var stampedAt: Date
}
