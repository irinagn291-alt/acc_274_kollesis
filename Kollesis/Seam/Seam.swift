import Foundation

/// A tappable joint between two adjacent tokens on the volumen.
struct Seam: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var jointIndex: Int
    var isCooled: Bool

    static func hung(on volumen: Volumen) -> [Seam] {
        guard volumen.tokens.count >= 2 else { return [] }
        return (0..<(volumen.tokens.count - 1)).map { index in
            Seam(id: UUID(), jointIndex: index, isCooled: false)
        }
    }
}
