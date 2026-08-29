# MuTTY

MuTTY steht für -MacOS ultra teletypewriter-

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

<img width="896" height="554" alt="image" src="https://github.com/user-attachments/assets/fb14dd85-02b7-4d63-a1f7-6c383c1b8d2f" />


# MuTTY
MuTTY stands for -MacOS ultra teletypewriter-

A native macOS app for managing and launching SSH connections –
similar to PuTTY’s profile manager.

## Features
Create, edit, duplicate, and delete any number of connection profiles

Store per profile: name, group, host, port, user, SSH key, and
additional SSH arguments

Group view in the sidebar + search field for filtering

Clicking “Connect” opens the SSH session in Terminal.app

Profiles are stored as JSON at
~/Library/Application Support/MuTTY/profiles.json

### Security
Passwords are deliberately not stored. Authentication is handled via
the SSH agent, the macOS Keychain, or – if no credentials are configured –
the regular login prompt in Terminal. Only the SSH key path is stored,
not the key itself.

## Installation (on Mac)
This app can only be compiled under macOS. The included .dmg is therefore
created on your Mac – not in the cloud.

Install Xcode Command Line Tools (if not already installed):

bash
xcode-select --install
Change to the project directory and start the build script:

bash
cd MuTTY
chmod +x build_dmg.sh
./build_dmg.sh
At the end, MuTTY.dmg will be located in the project directory. Double-click
it to open the installer – drag MuTTY.app into the Applications folder, done.

The first time you click “Connect”, macOS will ask for permission to allow
MuTTY to control Terminal
(System Settings › Privacy & Security › Automation › MuTTY ›
enable Terminal). If permission is denied, the app copies the completed
ssh command to the clipboard as a fallback.

## System Requirements
macOS 14 (Sonoma) or newer – also works under macOS Tahoe (macOS 26)

Xcode Command Line Tools (for swiftc)

## Project Structure
text
MuTTY/
├── Sources/
│   ├── MuTTYApp.swift   # App entry point (@main)
│   ├── SSHProfile.swift         # Data model
│   ├── ProfileStore.swift       # Persistence (JSON)
│   ├── TerminalLauncher.swift   # Launches ssh in Terminal.app
│   ├── ContentView.swift        # Main view (profile list)
│   └── ProfileEditView.swift    # Profile editor
├── AppIcon.png                  # Source icon (1024x1024)
├── generate_icon.py             # Generates AppIcon.png
├── build_dmg.sh                 # Compiles + creates the .dmg
└── README.md
Notes
The build script exits with a clear message if it is not running under
macOS.

The app is ad-hoc signed (not with an Apple Developer ID). On the first
launch, you may need to right-click the app and select “Open”.
