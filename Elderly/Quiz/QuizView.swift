import SwiftUI

/// La partita al quiz, tutta in una schermata (niente scorrimento): sopra chi gioca e la domanda,
/// al centro due foto grandissime, sotto il messaggio e la voce che legge.
struct QuizView: View {
    @State private var modello: QuizModello
    @Environment(\.dismiss) private var chiudi

    init(quiz: Quiz, giocatori: [Partecipante]) {
        _modello = State(initialValue: QuizModello(quiz: quiz, giocatori: giocatori))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme: \(modello.puntiTotali) risposte giuste su \(modello.totale)"
                        : "Risposte giuste al primo colpo: \(modello.puntiTotali) su \(modello.totale)",
                    ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito {
                BarraGiocatori(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)
                contatoreDomande
            }
        }
        .coloreSfondoDelTurno(modello.giocatori, turno: modello.turno)
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.success, trigger: modello.rivelata) { _, nuova in nuova != nil && modello.sbagliate.isEmpty }
        .sensoryFeedback(.warning, trigger: modello.sbagliate.count) { prima, dopo in dopo > prima }
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .onChange(of: modello.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .onChange(of: modello.turno) { _, nuovo in
            if modello.giocatori.count > 1, modello.giocatori[nuovo].haNome {
                AccessibilityNotification.Announcement("Tocca a \(modello.giocatori[nuovo].nome)").post()
            }
        }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            Text(modello.domanda.testo)
                .testo(DimensioneTesto.grande)
                .foregroundStyle(Tema.testo)
                .multilineTextAlignment(.center)
                .lineLimit(2).minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)

            // le foto prendono tutto lo spazio che resta: più alte che larghe (4:3, ritagliate ai lati) per essere il più grandi possibile
            GeometryReader { spazio in
                let distanza: CGFloat = 24
                let larghezza = (spazio.size.width - distanza * CGFloat(modello.risposte.count - 1)) / CGFloat(modello.risposte.count)
                let altezza = min(spazio.size.height, larghezza * 0.9)
                HStack(spacing: distanza) {
                    ForEach(modello.risposte) { risposta in
                        Button { modello.scegli(risposta) } label: {
                            SchedaRisposta(risposta: risposta, stato: stato(di: risposta))
                                .frame(width: larghezza, height: altezza)
                        }
                        .buttonStyle(StilePremuto())
                        .accessibilityLabel(risposta.testo)
                    }
                }
                .frame(width: spazio.size.width, height: spazio.size.height)
            }
            .grandezzaFoto()

            HStack(spacing: 24) {
                Text(modello.messaggio)
                    .testo(DimensioneTesto.grande)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta la domanda")
            }
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    private var contatoreDomande: some View {
        Text("\(modello.indice + 1) di \(modello.totale)")
            .testo(DimensioneTesto.medio)
            .foregroundStyle(Tema.testoSecondario)
            .fixedSize()
            .accessibilityLabel("Domanda \(modello.indice + 1) di \(modello.totale)")
    }

    private func stato(di risposta: RispostaQuiz) -> SchedaRisposta.Stato {
        if modello.rivelata == risposta.id { return .giusta }
        if modello.sbagliate.contains(risposta.id) { return .sbagliata }
        return .normale
    }
}
