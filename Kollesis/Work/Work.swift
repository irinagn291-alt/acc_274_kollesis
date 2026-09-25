import Foundation

/// A saved painting on the roll. Explore writes Loose. Glue samples a Work
/// that is not Parted. Identity is the catalog object id, not a list index.
struct Work: Codable, Sendable, Identifiable, Equatable, Hashable {
    let id: UUID
    let objectId: String
    var artist: String
    var title: String
    var imageURL: String?
    var accession: String?
    var filing: WorkFiling
    var dayKey: Int

    var tokenCount: Int {
        RollTokens.split(artist).count + RollTokens.split(title).count
    }

    var canGlue: Bool {
        filing != .parted && tokenCount >= 3
    }
}
