import SwiftUI
import SwiftData

/// Fine partita, uguale per tutti i giochi: si festeggia insieme, senza classifiche.
struct RisultatoPartitaView: View {
    let gioco: Gioco
    let giocatori: [Partecipante]
    let punti: [Int]
    let sommario: String          // per esempio "Insieme: 5 risposte giuste su 6"
    var totale: Int? = nil        // il massimo possibile, salvato nei risultati
    var squadra: Int? = nil       // punteggio unico di tutti, nei giochi senza turni
    let ricomincia: () -> Void
    let esci: () -> Void
    @Environment(\.modelContext) private var contesto

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
        .scorriSeServe()
        .onAppear {
            AccessibilityNotification.Announcement("\(Frasi.bravi(giocatori)) La partita è finita").post()
            Risultato.salva(gioco: gioco, giocatori: giocatori, punti: punti, squadra: squadra, totale: totale, in: contesto)
        }
    }
}
