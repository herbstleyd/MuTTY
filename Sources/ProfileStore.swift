import Foundation
import Combine

/// Hält alle Profile im Speicher und persistiert sie als JSON in
/// ~/Library/Application Support/MuTTY/profiles.json
final class ProfileStore: ObservableObject {

    @Published private(set) var profiles: [SSHProfile] = []

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let base = (try? fm.url(for: .applicationSupportDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: true))
            ?? URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Support")

        let dir = base.appendingPathComponent("MuTTY", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("profiles.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoded = (try? JSONDecoder().decode([SSHProfile].self, from: data)) ?? []
        profiles = decoded.sorted {
            $0.group.localizedCaseInsensitiveCompare($1.group) == .orderedAscending
                || ($0.group.caseInsensitiveCompare($1.group) == .orderedSame
                    && $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending)
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(profiles)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Datei könnte z.B. schreibgeschützt sein – dann einfach weiterlaufen.
            print("Profile konnten nicht gespeichert werden: \(error)")
        }
    }

    func upsert(_ profile: SSHProfile) {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
        } else {
            profiles.append(profile)
        }
        save()
    }

    func delete(_ profile: SSHProfile) {
        profiles.removeAll(where: { $0.id == profile.id })
        save()
    }

    func duplicate(_ profile: SSHProfile) -> SSHProfile {
        var copy = profile
        copy.id = UUID()
        copy.name = "\(profile.name) (Kopie)"
        upsert(copy)
        return copy
    }
}
