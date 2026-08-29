import SwiftUI

@main
struct MuTTYApp: App {
    @StateObject private var store = ProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 760, minHeight: 440)
                .environmentObject(store)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 900, height: 560)
    }
}
