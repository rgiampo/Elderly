import SwiftUI
import SwiftData

@main
struct ElderlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Utente.self) // crea e gestisce il database delle persone
    }
}
