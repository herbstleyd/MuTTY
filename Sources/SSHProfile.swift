import Foundation

/// Ein gespeichertes SSH-Verbindungsprofil.
/// Passwörter werden bewusst NICHT gespeichert – die Authentifizierung
/// erfolgt über SSH-Agent / macOS-Keychain bzw. den Login-Prompt im Terminal.
struct SSHProfile: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String        // Anzeigename
    var group: String      // optionale Gruppe / Tag
    var host: String       // Zielrechner (IP oder Hostname)
    var port: Int          // SSH-Port
    var username: String    // Benutzername
    var identityFile: String // Pfad zu SSH-Key (optional)
    var extraArgs: String  // weitere SSH-Argumente (optional, fortgeschritten)

    init(id: UUID = UUID(),
         name: String = "",
         group: String = "",
         host: String = "",
         port: Int = 22,
         username: String = "",
         identityFile: String = "",
         extraArgs: String = "") {
        self.id = id
        self.name = name
        self.group = group
        self.host = host
        self.port = port
        self.username = username
        self.identityFile = identityFile
        self.extraArgs = extraArgs
    }

    /// Kurze Zusammenfassung wie "user@host:port".
    var summary: String {
        let target = username.isEmpty ? host : "\(username)@\(host)"
        return "\(target):\(port)"
    }
}
