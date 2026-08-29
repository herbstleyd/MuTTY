# MuTTY

Eine native macOS-App zum Verwalten und Starten von SSH-Verbindungen –
ähnlich dem Profil-Manager von PuTTY.

## Was sie kann

- Beliebig viele Verbindungsprofile anlegen, bearbeiten, duplizieren und löschen
- Pro Profil speichern: Bezeichnung, Gruppe, Host, Port, Benutzer, SSH-Key und
  weitere SSH-Argumente
- Gruppenansicht in der Sidebar + Suchfeld zum Filtern
- Ein Klick auf „Verbinden" öffnet die SSH-Sitzung in Terminal.app
- Profile werden als JSON gespeichert unter
  `~/Library/Application Support/MuTTY/profiles.json`

### Sicherheit

Passwörter werden bewusst **nicht** gespeichert. Die Anmeldung erfolgt über
den SSH-Agent bzw. die macOS-Keychain oder – falls nichts hinterlegt ist – über
den normalen Login-Prompt im Terminal. Der SSH-Key-Pfad wird nur gespeichert,
nicht der Schlüssel selbst.

## Installation (auf dem Mac)

> Diese App kann nur unter macOS kompiliert werden. Die beigelegte `.dmg` wird
> daher **auf deinem Mac** erzeugt – nicht in der Cloud.

1. **Xcode Command Line Tools** installieren (falls noch nicht vorhanden):
   ```bash
   xcode-select --install
   ```

2. In den Projektordner wechseln und das Build-Skript starten:
   ```bash
   cd MuTTY
   chmod +x build_dmg.sh
   ./build_dmg.sh
   ```

3. Am Ende liegt `MuTTY.dmg` im Projektordner. Doppelklick öffnet den
   Installer – `MuTTY.app` in den Programme-Ordner ziehen, fertig.

Beim ersten „Verbinden" fragt macOS einmalig nach der Erlaubnis, dass
MuTTY Terminal steuern darf
(Systemeinstellungen › Datenschutz & Sicherheit › Automation › MuTTY ›
Terminal aktivieren). Wird die Abfrage verneint, kopiert die App den fertigen
ssh-Befehl in die Zwischenablage als Fallback.

## Systemanforderungen

- macOS 14 (Sonoma) oder neuer – funktioniert auch unter macOS Tahoe (macOS 26)
- Xcode Command Line Tools (für `swiftc`)

## Projektstruktur

```
MuTTY/
├── Sources/
│   ├── MuTTYApp.swift   # App-Einstieg (@main)
│   ├── SSHProfile.swift         # Datenmodell
│   ├── ProfileStore.swift       # Persistenz (JSON)
│   ├── TerminalLauncher.swift   # Startet ssh in Terminal.app
│   ├── ContentView.swift        # Hauptansicht (Profilliste)
│   └── ProfileEditView.swift    # Profil-Editor
├── AppIcon.png                  # Quell-Icon (1024x1024)
├── generate_icon.py             # erzeugt AppIcon.png
├── build_dmg.sh                 # kompiliert + erzeugt die .dmg
└── README.md
```

## Hinweise

- Das Build-Skript bricht mit einer klaren Meldung ab, falls es nicht unter
  macOS läuft.
- Die App wird ad-hoc signiert (nicht mit einer Apple-Entwickler-ID). Beim
  ersten Start ggf. Rechtsklick auf die App → „Öffnen" wählen.
