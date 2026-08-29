import SwiftUI

struct ProfileEditView: View {
    @Binding var profile: SSHProfile
    let isNew: Bool
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isNew ? "Neues Profil" : "Profil bearbeiten")
                .font(.headline)
                .padding(.bottom, 8)

            Form {
                Section("Verbindung") {
                    TextField("Bezeichnung", text: $profile.name)
                        .help("Frei wählbarer Name, z.B. 'Web-Server Prod'")
                    TextField("Gruppe", text: $profile.group)
                        .help("Optional, zur Sortierung in der Sidebar")
                    TextField("Host", text: $profile.host)
                        .help("IP-Adresse oder Hostname")
                    TextField("Benutzer", text: $profile.username)
                        .help("Login-Name auf dem Zielrechner")
                    HStack {
                        Text("Port")
                        Spacer()
                        Stepper(value: $profile.port, in: 1...65535) {
                            Text("\(profile.port)")
                                .monospacedDigit()
                        }
                    }
                }

                Section("Authentifizierung") {
                    TextField("Identity File (SSH-Key, optional)",
                               text: $profile.identityFile)
                        .help("Pfad zur privaten Schlüsseldatei, z.B. ~/.ssh/id_ed25519")
                    Text("Passwörter werden aus Sicherheitsgründen nicht gespeichert. Die Anmeldung erfolgt über den SSH-Agent / macOS-Keychain bzw. den Login-Prompt im Terminal.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Section("Erweitert") {
                    TextField("Weitere SSH-Argumente", text: $profile.extraArgs)
                        .help("z.B. -o StrictHostKeyChecking=no -o ConnectTimeout=10")
                    Text("Fortgeschritten: Diese Argumente werden 1:1 an ssh übergeben.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .formStyle(.grouped)
        }
        .padding()
        .frame(width: 520)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Abbrechen", action: onCancel)
                    .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern", action: onSave)
                    .keyboardShortcut(.defaultAction)
                    .disabled(profile.name.trimmingCharacters(in: .whitespaces).isEmpty
                              || profile.host.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
