import Foundation

/// Storage seam. Views never touch UserDefaults or files. IO stays off the
/// main thread. The in-memory document in RollStore is the source of truth.
actor RollVault {
    private let defaultsSuite: String?
    private let fileURL: URL
    private let backupURL: URL

    init(defaultsSuite: String? = nil, directory: URL? = nil) {
        self.defaultsSuite = defaultsSuite
        let root = directory ?? Self.applicationSupportDirectory()
        fileURL = root.appendingPathComponent("roll.json", isDirectory: false)
        backupURL = root.appendingPathComponent("roll.json.backup", isDirectory: false)
    }

    func load() async -> (RollDocument, RollDocument.DecodeIssue) {
        let fileManager = FileManager.default
        let primaryExists = fileManager.fileExists(atPath: fileURL.path)
        let backupExists = fileManager.fileExists(atPath: backupURL.path)
        let defaultsData = defaults().data(forKey: RollDocument.defaultsKey)
        let backupDefaults = defaults().data(forKey: RollDocument.backupKey)
        if let data = Self.readFile(fileURL),
           let document = try? RollDocumentCodec.decode(data) {
            return (document, .none)
        }
        if let data = Self.readFile(backupURL),
           let document = try? RollDocumentCodec.decode(data) {
            return (document, .recoveredFromBackup)
        }
        if let data = backupDefaults,
           let document = try? RollDocumentCodec.decode(data) {
            return (document, .recoveredFromBackup)
        }
        if let data = defaultsData,
           let document = try? RollDocumentCodec.decode(data) {
            return (document, primaryExists || backupExists ? .recoveredFromBackup : .none)
        }
        if primaryExists || backupExists || defaultsData != nil || backupDefaults != nil {
            return (.empty, .startedEmpty)
        }
        return (.empty, .none)
    }

    func persist(_ document: RollDocument) async throws {
        try Task.checkCancellation()
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try RollDocumentCodec.encode(document)
        if let current = Self.readFile(fileURL) {
            defaults().set(current, forKey: RollDocument.backupKey)
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            try fileManager.copyItem(at: fileURL, to: backupURL)
        }
        try data.write(to: fileURL, options: .atomic)
        defaults().set(data, forKey: RollDocument.defaultsKey)
    }

    func wipe() async throws {
        let fileManager = FileManager.default
        defaults().removeObject(forKey: RollDocument.defaultsKey)
        defaults().removeObject(forKey: RollDocument.backupKey)
        defaults().removeObject(forKey: RollDocument.demoKey)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }
    }

    func replaceFileWithCorruptData(_ data: Data) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
        defaults().set(data, forKey: RollDocument.defaultsKey)
    }

    func markDemoSeeded() {
        defaults().set(true, forKey: RollDocument.demoKey)
    }

    func isDemoSeeded() -> Bool {
        defaults().bool(forKey: RollDocument.demoKey)
    }

    private func defaults() -> UserDefaults {
        if let defaultsSuite {
            return UserDefaults(suiteName: defaultsSuite) ?? .standard
        }
        return .standard
    }

    nonisolated private static func readFile(_ url: URL) -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    nonisolated private static func applicationSupportDirectory() -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return root.appendingPathComponent("Kollesis", isDirectory: true)
    }
}
