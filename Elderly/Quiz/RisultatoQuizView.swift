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
                .font(.system(size: 96, weight: .heavy, design: .rounded))

            Text(plurale ? "Insieme: \(modello.puntiTotali) risposte giuste su \(modello.totale)"
                         : "Risposte giuste al primo colpo: \(modello.puntiTotali) su \(modello.totale)")
                .testo(DimensioneTesto.grande, .semibold)
                .multilineTextAlignment(.center)

            if plurale { BarraGiocatori(giocatori: modello.giocatori, punti: modello.punti) }

            Button(action: ricomincia) {
                Text("Gioca ancora").testo(DimensioneTesto.grande, .heavy)
                    .foregroundStyle(.white).frame(maxWidth: 520, minHeight: 90)
            }
            .buttonStyle(.glassProminent).tint(Tema.azzurroProfondo)

            Button(action: esci) {
                Text("Torna ai quiz").testo(DimensioneTesto.medio, .bold)
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
