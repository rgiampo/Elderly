import SwiftUI

struct GiocoView: View {
    @State private var partita: PartitaModello
    @ScaledMetric(relativeTo: .largeTitle) private var messaggio = 84
    @ScaledMetric(relativeTo: .largeTitle) private var lato = 230

    private let giocatori: [Partecipante]

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        _partita = State(initialValue: PartitaModello(giocatori: giocatori.count, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(spacing: 28) {
                    BarraGiocatori(giocatori: giocatori, turno: partita.giocatoreCorrente)
                    BannerTurno(giocatori: giocatori, turno: partita.giocatoreCorrente)

                    Text(partita.messaggio)
                        .font(.system(size: messaggio, weight: .heavy, design: .rounded))
                        .foregroundStyle(Tema.testo)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 56).padding(.vertical, 24)
                        .glassEffect(.regular, in: .rect(cornerRadius: 56))
                        .contentTransition(.opacity)
                        .accessibilityAddTraits(.isHeader)

                    riga

                    Text("Sequenza più lunga insieme: \(partita.record)")
                        .testo(DimensioneTesto.medio, .semibold)
                        .foregroundStyle(Tema.testoSecondario)

                    BottoneVoce(testo: Istruzioni.comeSiGioca)
                        .padding(.horizontal, 60)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }

            if partita.fase == .festa { Coriandoli().allowsHitTesting(false) }
        }
        .animation(.easeInOut, value: partita.messaggio)
        .sensoryFeedback(.impact(weight: .medium), trigger: partita.formaAccesa) { _, nuova in nuova != nil }
        .sensoryFeedback(trigger: partita.fase) { _, nuova in nuova == .festa ? .success : nil }
        .onChange(of: partita.messaggio) { _, nuovo in
            AccessibilityNotification.Announcement(nuovo).post()
        }
        .animation(.spring(duration: 0.5), value: partita.giocatoreCorrente)
        .sensoryFeedback(.impact(weight: .heavy), trigger: partita.giocatoreCorrente) { _, _ in giocatori.count > 1 }
        .onAppear { partita.inizia() }
        .onDisappear { partita.ferma() }
    }

    /// Le forme stanno sempre tutte in una riga: se manca spazio diventano più piccole, non scorrono.
    private var riga: some View {
        GeometryReader { spazio in
            let quante = CGFloat(partita.forme.count)
            let distanza: CGFloat = 28
            // 0.9: la forma illuminata cresce del 10% e non deve uscire dallo schermo
            let latoForma = min(lato, (spazio.size.width - distanza * (quante - 1)) / quante * 0.9)
            HStack(spacing: distanza) {
                ForEach(partita.forme) { forma in
                    FormaBottone(forma: forma, accesa: partita.formaAccesa == forma, lato: latoForma) {
                        partita.tocca(forma)
                    }
                }
            }
            .frame(width: spazio.size.width, height: spazio.size.height)
        }
        .frame(height: lato + 40)
        .padding(.horizontal, 40)
    }
}

/// Pezzo di gioco: quando suona si illumina e cresce. Tutta la sagoma è sensibile al tocco.
struct FormaBottone: View {
    let forma: Forma
    let accesa: Bool
    let lato: CGFloat
    let azione: () -> Void

    var body: some View {
        Button(action: azione) {
            forma.sagoma
                .fill(forma.colore)
                .overlay(forma.sagoma.stroke(.white.opacity(0.55), lineWidth: 6))
                .frame(width: lato, height: lato)
                .contentShape(forma.sagoma)
        }
        .buttonStyle(StilePremuto())
        .brightness(accesa ? 0.15 : 0)
        .scaleEffect(accesa ? 1.1 : 1)
        .shadow(color: forma.colore.opacity(accesa ? 0.8 : 0.25), radius: accesa ? 40 : 10, y: 6)
        .accessibilityLabel(forma.nome)
        .accessibilityHint("Tocca per suonare")
    }
}

/// Piccola festa: pallini colorati che cadono una volta sola.
struct Coriandoli: View {
    @State private var cadi = false
    private let pezzi = (0..<40).map { _ in
        (x: CGFloat.random(in: 0...1), ritardo: Double.random(in: 0...0.6),
         dimensione: CGFloat.random(in: 14...30), forma: Forma.allCases.randomElement()!)
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(pezzi.indices, id: \.self) { i in
                pezzi[i].forma.sagoma
                    .fill(pezzi[i].forma.colore)
                    .frame(width: pezzi[i].dimensione, height: pezzi[i].dimensione)
                    .position(x: pezzi[i].x * geo.size.width, y: cadi ? geo.size.height + 40 : -40)
                    .animation(.easeIn(duration: 2).delay(pezzi[i].ritardo), value: cadi)
            }
        }
        .onAppear { cadi = true }
    }
}

#Preview(traits: .landscapeLeft) {
    GiocoView(giocatori: [.senzaNome], difficolta: .medio)
}
