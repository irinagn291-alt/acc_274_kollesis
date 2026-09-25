import Foundation

/// One glued caption: artist tokens then title tokens XOR title then artist
/// as a single run. The field boundary is the joint between those two fields.
struct Volumen: Codable, Sendable, Equatable {
    var workId: UUID
    var tokens: [VolumenWord]
    var fieldBoundary: Int
    var artistLeads: Bool

    static func glued(from work: Work) -> Volumen? {
        let artist = RollTokens.split(work.artist)
        let title = RollTokens.split(work.title)
        guard artist.count + title.count >= 3, !artist.isEmpty, !title.isEmpty else {
            return nil
        }
        let artistLeads = RollTokens.artistLeads(objectId: work.objectId)
        let texts = artistLeads ? artist + title : title + artist
        let boundary = artistLeads ? artist.count - 1 : title.count - 1
        let words = texts.map { VolumenWord(id: UUID(), text: $0) }
        return Volumen(workId: work.id, tokens: words, fieldBoundary: boundary, artistLeads: artistLeads)
    }
}

struct VolumenWord: Codable, Sendable, Identifiable, Equatable {
    let id: UUID
    var text: String
}
