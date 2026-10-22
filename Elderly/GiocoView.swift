import SwiftUI

struct GiocoView: View {
    @State private var partita: PartitaModello
    @ScaledMetric(relativeTo: .largeTitle) private var messaggio = 72
    @ScaledMetric(relativeTo: .largeTitle) private var lato = 230

    init(giocatori: Int, difficolta: Difficolta) {
        _partita = State(initialValue: PartitaModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(spacing: 28) {
                    if partita.giocatori > 1 {
                        Text("Tocca a: Giocatore \(partita.giocatoreCorrente + 1)")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(Tema.testoSecondario)
                    }

                    Text(partita.messaggio)
                        .font(.system(size: messaggio, weight: .heavy, design: .rounded))
                        .foregroundStyle(Tema.testo)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 56).padding(.vertical, 24)
                        .glassEffect(.regular, in: .rect(cornerRadius: 56))
                        .contentTransition(.opacity)
                        .accessibilityAddTraits(.isHeader)

                    ViewThatFits(in: .horizontal) {
                        riga
                        ScrollView(.horizontal) { riga.padding(.horizontal) }
                    }

                    Text("Sequenza più lunga insieme: \(partita.record)")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
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
        .onAppear { partita.inizia() }
        .onDisappear { partita.ferma() }
    }

    private var riga: some View {
        HStack(spacing: 36) {
            ForEach(partita.forme) { forma in
                FormaBottone(forma: forma, accesa: partita.formaAccesa == forma, lato: lato) {
                    partita.tocca(forma)
                }
            }
        }
    }
}

/// Pezzo di gioco in vetro colorato: reagisce al tocco e, quando suona, si illumina e cresce.
struct FormaBottone: View {
    let forma: Forma
    let accesa: Bool
    let lato: CGFloat
    let azione: () -> Void

    var body: some View {
        Button(action: azione) {
            Color.clear.frame(width: lato, height: lato)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(forma.colore).interactive(), in: forma.sagoma)
        .brightness(accesa ? 0.15 : 0)
        .scaleEffect(accesa ? 1.1 : 1)
        .shadow(color: forma.colore.opacity(accesa ? 0.8 : 0), radius: 40)
        .contentShape(forma.sagoma)
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
    GiocoView(giocatori: 3, difficolta: .medio)
}
