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
                .statusBarHidden(true)                       // schermo intero: niente ora, data e batteria in alto
                .persistentSystemOverlays(.hidden)           // nasconde anche la barra in basso
                .tint(Tema.blu)
        }
        // crea e gestisce il database: persone, quiz creati e risultati delle partite
        .modelContainer(for: [Utente.self, QuizCreato.self, Risultato.self])
    }
}
