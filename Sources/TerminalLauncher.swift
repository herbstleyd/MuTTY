import AppKit
import Foundation

/// Öffnet eine SSH-Verbindung in Terminal.app.
///
/// Es wird bewusst auf AppleScript `do script` gesetzt, damit ein neues
/// Terminal-Fenster/-Tab geöffnet und der ssh-Befehl darin gestartet wird.
/// Beim ersten Aufruf fragt macOS nach der Berechtigung, diese App darf
/// Terminal steuern (Systemeinstellungen › Datenschutz & Sicherheit › Automation).
enum TerminalLauncher {

    /// Startet die Verbindung. Liefert im Fehlerfall eine Klartextmeldung zurück.
    @discardableResult
    static func connect(to profile: SSHProfile) -> String? {
        let command = appleEscape(profile.shellCommandLine())
        let appleScript = """
        tell application "Terminal"
            activate
            if (count of windows) is 0 then
                do script "\(command)"
            else
                do script "\(command)" in window 1
            end if
        end tell
        """

        var errorInfo: NSDictionary?
        if let script = NSAppleScript(source: appleScript) {
            script.executeAndReturnError(&errorInfo)
        }

        if let errorInfo = errorInfo {
            // Fallback: Befehl in die Zwischenablage kopieren, damit der Nutzer
            // ihn manuell in ein Terminal einfügen kann.
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(profile.shellCommandLine(), forType: .string)
            let errorText = (errorInfo["NSLocalizedDescription"] as? String) ?? "unbekannt"
            return "Terminal konnte nicht automatisch gesteuert werden (\(errorText)). " +
                   "Der ssh-Befehl wurde in die Zwischenablage kopiert – bitte ein Terminal öffnen und einfügen."
        }
        return nil
    }

    /// Maskiert einen Shell-Befehl für die Verwendung innerhalb eines
    /// AppleScript-Stringliterals (do script "...").
    private static func appleEscape(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\")
             .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

private extension SSHProfile {
    /// Liefert den fertigen, sicher quotierten ssh-Befehl als reinen Shell-String.
    func shellCommandLine() -> String {
        var parts: [String] = ["ssh"]
        if port != 22 {
            parts.append("-p")
            parts.append(String(port))
        }
        if !identityFile.isEmpty {
            parts.append("-i")
            parts.append(shellQuote(expandedPath(identityFile)))
        }
        if !extraArgs.isEmpty {
            parts.append(extraArgs)
        }
        let target = username.isEmpty ? host : "\(username)@\(host)"
        parts.append(shellQuote(target))
        return parts.joined(separator: " ")
    }

    /// Single-Quote-Escaping für die Shell: ' --> '\''
    func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    /// Expandiert ein führendes `~` zum Home-Verzeichnis, da die Shell
    /// innerhalb von Single-Quotes keine Tilde expandiert.
    func expandedPath(_ value: String) -> String {
        if value == "~" { return NSHomeDirectory() }
        if value.hasPrefix("~/") {
            return NSHomeDirectory() + String(value.dropFirst())
        }
        return value
    }
}
