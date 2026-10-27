import SwiftUI

/// La partita al quiz: domanda grande, risposte con foto, voce che legge tutto.
struct QuizView: View {
    @State private var modello: QuizModello
    @Environment(\.dismiss) private var chiudi
    @ScaledMetric(relativeTo: .largeTitle) private var testoDomanda = 68

    init(quiz: Quiz, giocatori: [Partecipante]) {
        _modello = State(initialValue: QuizModello(quiz: quiz, giocatori: giocatori))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            ScrollView {
                if modello.finito { RisultatoQuizView(modello: modello, ricomincia: modello.ricomincia, esci: { chiudi() }) }
                else { partita }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: modello.rivelata) { _, nuova in nuova != nil }
        .sensoryFeedback(.warning, trigger: modello.sbagliate.count) { prima, dopo in dopo > prima }
        .onChange(of: modello.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 28) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    BarraGiocatori(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)
                    Spacer(minLength: 24)
                    contatoreDomande
                }
                VStack(alignment: .leading, spacing: 12) {
                    BarraGiocatori(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)
                    contatoreDomande
                }
            }

            Text(modello.domanda.testo)
                .font(.system(size: testoDomanda, weight: .heavy, design: .rounded))
                .foregroundStyle(Tema.testo)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 360), spacing: 28)], spacing: 28) {
                ForEach(modello.risposte) { risposta in
                    Button { modello.scegli(risposta) } label: {
                        SchedaRisposta(risposta: risposta, stato: stato(di: risposta))
                    }
                    .buttonStyle(StilePremuto())
                    .accessibilityLabel(risposta.testo)
                }
            }

            Text(modello.messaggio.isEmpty ? " " : modello.messaggio)
                .testo(DimensioneTesto.grande, .bold)
                .foregroundStyle(Tema.testo)

            BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta la domanda")
        }
        .padding(40)
        .frame(maxWidth: 1200)
        .frame(maxWidth: .infinity)
    }

    private var contatoreDomande: some View {
        Text("Domanda \(modello.indice + 1) di \(modello.totale)")
            .testo(DimensioneTesto.normale, .semibold)
            .foregroundStyle(Tema.testoSecondario)
            .fixedSize()
    }

    private func stato(di risposta: RispostaQuiz) -> SchedaRisposta.Stato {
        if modello.rivelata == risposta.id { return .giusta }
        if modello.sbagliate.contains(risposta.id) { return .sbagliata }
        return .normale
    }
}

