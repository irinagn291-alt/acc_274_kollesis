import Foundation

/// Local Isabella Stewart Gardner Museum shelf. Search hangs from here when
/// the wire is empty or fails. Never Open Food Facts. Never a shop.
enum GardnerShelf {
    static func stableID(_ objectId: String) -> UUID {
        var digest = [UInt8](repeating: 0, count: 16)
        for (offset, byte) in objectId.utf8.enumerated() {
            digest[offset % 16] = digest[offset % 16] &+ byte &+ UInt8(truncatingIfNeeded: offset)
        }
        digest[6] = (digest[6] & 0x0F) | 0x40
        digest[8] = (digest[8] & 0x3F) | 0x80
        return UUID(uuid: (
            digest[0], digest[1], digest[2], digest[3],
            digest[4], digest[5], digest[6], digest[7],
            digest[8], digest[9], digest[10], digest[11],
            digest[12], digest[13], digest[14], digest[15]
        ))
    }

    static func seedWorks() -> [Work] {
        catalog.map(\.asWork)
    }

    static func hunt(query: String) -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return seedWorks() }
        return catalog.filter { row in
            row.artist.lowercased().contains(trimmed)
                || row.title.lowercased().contains(trimmed)
                || row.objectId.lowercased().contains(trimmed)
        }.map(\.asWork)
    }

    private struct Row {
        let objectId: String
        let artist: String
        let title: String
        let imageURL: String?
        let accession: String?

        var asWork: Work {
            Work(
                id: GardnerShelf.stableID(objectId),
                objectId: objectId,
                artist: artist,
                title: title,
                imageURL: imageURL,
                accession: accession,
                filing: .loose,
                dayKey: DayKey.from(Date())
            )
        }
    }

    private static let catalog: [Row] = [
        Row(
            objectId: "Q219831",
            artist: "Johannes Vermeer",
            title: "The Concert",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Johannes%20Vermeer%20-%20The%20Concert%20-%20Google%20Art%20Project.jpg",
            accession: "P21w27"
        ),
        Row(
            objectId: "Q3223591",
            artist: "John Singer Sargent",
            title: "El Jaleo",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/John%20Singer%20Sargent%20-%20El%20Jaleo%20-%20Google%20Art%20Project.jpg",
            accession: "P3s6"
        ),
        Row(
            objectId: "Q3948164",
            artist: "Titian",
            title: "The Rape of Europa",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Titian%20-%20The%20Rape%20of%20Europa%20-%20Google%20Art%20Project.jpg",
            accession: "P26e1"
        ),
        Row(
            objectId: "Q18688326",
            artist: "John Singer Sargent",
            title: "Isabella Stewart Gardner",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/John%20Singer%20Sargent%20-%20Isabella%20Stewart%20Gardner%20-%20Google%20Art%20Project.jpg",
            accession: "P17e21"
        ),
        Row(
            objectId: "Q20198722",
            artist: "Rembrandt",
            title: "Self Portrait Aged 23",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt%20-%20Self-Portrait%2C%20Age%2023%20-%20Google%20Art%20Project.jpg",
            accession: "P21n6"
        ),
        Row(
            objectId: "Q18688341",
            artist: "Botticelli",
            title: "The Story of Lucretia",
            imageURL: "https://commons.wikimedia.org/wiki/Special:FilePath/Sandro%20Botticelli%20-%20The%20Story%20of%20Lucretia%20-%20Google%20Art%20Project.jpg",
            accession: "P16e11"
        )
    ]
}
