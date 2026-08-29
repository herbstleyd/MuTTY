import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var store: ProfileStore

    @State private var searchText = ""
    @State private var selectedGroup: String? = "Alle"
    @State private var editingDraft: SSHProfile? = nil
    @State private var editingIsNew = false
    @State private var connectionError: String? = nil

    private let allGroup = "Alle"
    private let noGroup = "Ohne Gruppe"

    private var groups: [String] {
        let names = Set(store.profiles.map { $0.group.isEmpty ? noGroup : $0.group })
        let sortedNames = names.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
        return [allGroup] + sortedNames
    }

    private var filtered: [SSHProfile] {
        store.profiles.filter { p in
            let g = p.group.isEmpty ? noGroup : p.group
            let groupMatch = selectedGroup == nil
                || selectedGroup == allGroup
                || g == selectedGroup
            let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchMatch = q.isEmpty
                || p.name.localizedCaseInsensitiveContains(q)
                || p.host.localizedCaseInsensitiveContains(q)
                || p.username.localizedCaseInsensitiveContains(q)
                || p.group.localizedCaseInsensitiveContains(q)
            return groupMatch && searchMatch
        }
    }

    var body: some View {
        NavigationSplitView {
            List(groups, id: \.self, selection: $selectedGroup) { group in
                Label(group, systemImage: group == allGroup ? "tray.full" : "folder")
                    .tag(group)
            }
            .navigationTitle("Profile")
        } detail: {
            List {
                ForEach(filtered) { profile in
                    profileRow(profile)
                }
            }
            .listStyle(.inset)
            .searchable(text: $searchText, prompt: "Bezeichnung, Host oder Benutzer suchen")
            .toolbar { addToolbarItem }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Keine Profile",
                        systemImage: "tray",
                        description: Text("Lege ein neues Profil an, um eine SSH-Verbindung zu speichern.")
                    )
                }
            }
        }
        .sheet(item: $editingDraft) { _ in
            ProfileEditView(
                profile: Binding(
                    get: { editingDraft ?? SSHProfile() },
                    set: { editingDraft = $0 }
                ),
                isNew: editingIsNew,
                onSave: { commit(); editingDraft = nil },
                onCancel: { editingDraft = nil }
            )
        }
        .alert("Verbindung fehlgeschlagen",
               isPresented: Binding(
                   get: { connectionError != nil },
                   set: { if !$0 { connectionError = nil } }
               )) {
            Button("OK") { connectionError = nil }
        } message: {
            Text(connectionError ?? "")
        }
    }

    @ViewBuilder
    private func profileRow(_ profile: SSHProfile) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "terminal")
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.headline)
                Text(profile.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospaced()
                if !profile.group.isEmpty {
                    Text(profile.group)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Button {
                if let err = TerminalLauncher.connect(to: profile) {
                    connectionError = err
                }
            } label: {
                Label("Verbinden", systemImage: "play.fill")
            }
            .help("SSH-Verbindung in Terminal.app öffnen")
            .buttonStyle(.borderedProminent)

            Button {
                startEditing(profile)
            } label: {
                Image(systemName: "pencil")
            }
            .help("Profil bearbeiten")
            .buttonStyle(.borderless)

            Button {
                _ = store.duplicate(profile)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .help("Duplikat anlegen")
            .buttonStyle(.borderless)

            Button(role: .destructive) {
                store.delete(profile)
            } label: {
                Image(systemName: "trash")
            }
            .help("Profil löschen")
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }

    private var addToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: startAdding) {
                Label("Neu", systemImage: "plus")
            }
            .help("Neues Profil anlegen")
            .keyboardShortcut("n", modifiers: .command)
        }
    }

    private func startAdding() {
        editingIsNew = true
        editingDraft = SSHProfile()
    }

    private func startEditing(_ profile: SSHProfile) {
        editingIsNew = false
        editingDraft = profile
    }

    private func commit() {
        guard let draft = editingDraft else { return }
        store.upsert(draft)
    }
}
