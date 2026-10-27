import SwiftUI
import SwiftData

@main
struct ElderlyApp: App {
    @State private var sessione = Sessione()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessione)
                .preferredColorScheme(.light)   // i colori e i contrasti sono pensati per la modalità chiara
                .foregroundStyle(Tema.testo)
                .tint(Tema.blu)
        }
        // crea e gestisce il database: persone e quiz creati
        .modelContainer(for: [Utente.self, QuizCreato.self])
    }
}
