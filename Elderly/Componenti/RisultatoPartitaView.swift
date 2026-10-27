import SwiftUI

/// Fine partita, uguale per tutti i giochi: si festeggia insieme, senza classifiche.
struct RisultatoPartitaView: View {
    let giocatori: [Partecipante]
    let punti: [Int]
    let sommario: String          // per esempio "Insieme: 5 risposte giuste su 6"
    let ricomincia: () -> Void
    let esci: () -> Void

    private var plurale: Bool { giocatori.count > 1 }

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)
            Text(Frasi.bravi(giocatori))
                .testo(DimensioneTesto.enorme)
                .accessibilityAddTraits(.isHeader)

            Text(sommario)
                .testo(DimensioneTesto.grande)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)

            if plurale { BarraGiocatori(giocatori: giocatori, punti: punti) }

            HStack(spacing: 28) {
                Button(action: ricomincia) { PulsantePrincipale(titolo: "Gioca ancora") }
                    .buttonStyle(StilePremuto())
                Button(action: esci) { PulsanteSecondario(titolo: "Esci") }
                    .buttonStyle(StilePremuto())
            }
            .frame(maxWidth: 1000)
            Spacer(minLength: 0)
        }
        .foregroundStyle(Tema.testo)
        .padding(.horizontal, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { AccessibilityNotification.Announcement("\(Frasi.bravi(giocatori)) La partita è finita").post() }
    }
}
