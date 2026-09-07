import Foundation
import NanoBreaksCore

struct PersistenceStore {
    private let stateURL: URL

    init(fileManager: FileManager = .default) {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("NanoBreaks", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let newStateURL = directory.appendingPathComponent("state.json")

        // Preserve progress when upgrading from the app's original name.
        let legacyDirectoryName = ["20", "min"].joined()
        let legacyStateURL = base
            .appendingPathComponent(legacyDirectoryName, isDirectory: true)
            .appendingPathComponent("state.json")
        if !fileManager.fileExists(atPath: newStateURL.path),
           fileManager.fileExists(atPath: legacyStateURL.path) {
            try? fileManager.copyItem(at: legacyStateURL, to: newStateURL)
        }

        stateURL = newStateURL
    }

    func load() -> PersistedState? {
        guard let data = try? Data(contentsOf: stateURL) else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }

    func save(_ state: PersistedState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: stateURL, options: .atomic)
    }

    func delete() {
        try? FileManager.default.removeItem(at: stateURL)
    }
}
