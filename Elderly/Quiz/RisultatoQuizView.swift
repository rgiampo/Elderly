import SwiftUI

/// Fine partita: si festeggia insieme, senza classifiche.
struct RisultatoQuizView: View {
    let modello: QuizModello
    let ricomincia: () -> Void
    let esci: () -> Void

    private var plurale: Bool { modello.giocatori.count > 1 }

    var body: some View {
        VStack(spacing: 32) {
            Text(plurale ? "Bravissimi!" : "Bravissimo!")
                .font(.system(size: 88, weight: .heavy, design: .rounded))

            Text(plurale ? "Insieme: \(modello.puntiTotali) risposte giuste su \(modello.totale)"
                         : "Risposte giuste al primo colpo: \(modello.puntiTotali) su \(modello.totale)")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .multilineTextAlignment(.center)

            if plurale { BarraGiocatori(giocatori: modello.giocatori, punti: modello.punti) }

            Button(action: ricomincia) {
                Text("Gioca ancora").font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(.white).frame(maxWidth: 520, minHeight: 90)
            }
            .buttonStyle(.glassProminent).tint(Tema.azzurroProfondo)

            Button(action: esci) {
                Text("Torna ai quiz").font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Tema.testo).frame(maxWidth: 520, minHeight: 80)
            }
            .buttonStyle(.glass)
        }
        .foregroundStyle(Tema.testo)
        .padding(60)
        .frame(maxWidth: .infinity)
        .onAppear { AccessibilityNotification.Announcement("Bravissimi! Avete finito il quiz").post() }
    }
}
