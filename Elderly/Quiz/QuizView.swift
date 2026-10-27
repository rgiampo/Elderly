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
            GeometryReader { spazio in
                ScrollView {
                    if modello.finito { RisultatoQuizView(modello: modello, ricomincia: modello.ricomincia, esci: { chiudi() }) }
                    else { partita(altezzaFoto: altezzaFoto(in: spazio.size)) }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: modello.rivelata) { _, nuova in nuova != nil }
        .sensoryFeedback(.warning, trigger: modello.sbagliate.count) { prima, dopo in dopo > prima }
        .onChange(of: modello.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .onChange(of: modello.turno) { _, nuovo in
            if modello.giocatori.count > 1, modello.giocatori[nuovo].haNome {
                AccessibilityNotification.Announcement("Tocca a \(modello.giocatori[nuovo].nome)").post()
            }
        }
        .onDisappear { modello.ferma() }
    }

    private func partita(altezzaFoto: CGFloat) -> some View {
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

            BannerTurno(giocatori: modello.giocatori, turno: modello.turno)

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
                        SchedaRisposta(risposta: risposta, stato: stato(di: risposta), altezzaFoto: altezzaFoto)
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

    /// Le foto occupano tutto lo spazio rimasto, così domanda, foto e bottone stanno nello schermo
    /// senza scorrere (in orizzontale e in verticale, con 2 o 3 risposte).
    private func altezzaFoto(in spazio: CGSize) -> CGFloat {
        let minimoLarghezza: CGFloat = 360, distanza: CGFloat = 28, margini: CGFloat = 80
        let perRiga = max(1, Int((spazio.width - margini + distanza) / (minimoLarghezza + distanza)))
        let righe = (modello.risposte.count + perRiga - 1) / perRiga
        let altroSulloSchermo: CGFloat = 560   // barra giocatori, domanda, messaggio, bottone vocale, margini
        let disponibile = (spazio.height - altroSulloSchermo - distanza * CGFloat(righe - 1)) / CGFloat(max(righe, 1))
        return min(520, max(240, disponibile))
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

