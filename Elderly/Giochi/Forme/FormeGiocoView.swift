import SwiftUI

/// "Suona le forme", tutto in una schermata: sopra chi gioca, al centro le forme grandi, sotto il messaggio.
struct FormeGiocoView: View {
    @State private var partita: PartitaModello
    @Environment(\.dismiss) private var chiudi

    private let giocatori: [Partecipante]

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        _partita = State(initialValue: PartitaModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()

            VStack(spacing: 16) {
                BannerTurno(giocatori: giocatori, turno: partita.giocatoreCorrente)

                Text(partita.messaggio)
                    .testo(DimensioneTesto.titolo)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, minHeight: 90)
                    .contentTransition(.opacity)
                    .accessibilityAddTraits(.isHeader)

                RigaForme(partita: partita)
                    .frame(maxHeight: .infinity)

                HStack(spacing: 24) {
                    Text("Sequenza più lunga insieme: \(partita.record)")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testoSecondario)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    BottoneVoce(testo: Istruzioni.forme, etichetta: "Ascolta come si gioca")
                }
            }
            .padding(.horizontal, 40).padding(.bottom, 24)

            if partita.fase == .festa { Coriandoli().allowsHitTesting(false) }
        }
        .conIndietro { BarraGiocatori(giocatori: giocatori, turno: partita.giocatoreCorrente) }
        .bordoTurno(giocatori, turno: partita.giocatoreCorrente)
        .animation(.easeInOut, value: partita.messaggio)
        .animation(.spring(duration: 0.5), value: partita.giocatoreCorrente)
        .sensoryFeedback(.impact(weight: .medium), trigger: partita.formaAccesa) { _, nuova in nuova != nil }
        .sensoryFeedback(.impact(weight: .heavy), trigger: partita.giocatoreCorrente) { _, _ in giocatori.count > 1 }
        .sensoryFeedback(trigger: partita.fase) { _, nuova in nuova == .festa ? .success : nil }
        .onChange(of: partita.messaggio) { _, nuovo in AccessibilityNotification.Announcement(nuovo).post() }
        .onAppear { partita.inizia() }
        .onDisappear { partita.ferma() }
    }
}

/// Le forme, sempre tutte in una riga: se manca spazio diventano più piccole, non scorrono.
private struct RigaForme: View {
    let partita: PartitaModello

    var body: some View {
        GeometryReader { spazio in
            let quante = CGFloat(partita.forme.count)
            let distanza: CGFloat = 32
            // 0.88: la forma illuminata cresce un po' e non deve uscire dallo schermo
            let lato = min(spazio.size.height, (spazio.size.width - distanza * (quante - 1)) / quante) * 0.88
            HStack(spacing: distanza) {
                ForEach(partita.forme) { forma in
                    FormaBottone(forma: forma, accesa: partita.formaAccesa == forma, lato: lato) {
                        partita.tocca(forma)
                    }
                }
            }
            .frame(width: spazio.size.width, height: spazio.size.height)
        }
    }
}

/// Pezzo di gioco: quando suona si illumina, cresce e manda un'onda. Tutta la sagoma risponde al tocco.
struct FormaBottone: View {
    let forma: Forma
    let accesa: Bool
    let lato: CGFloat
    let azione: () -> Void

    /// 0 = l'onda parte, 1 = è sparita.
    @State private var onda: CGFloat = 1

    var body: some View {
        Button(action: azione) {
            forma.sagoma
                .fill(forma.colore)
                .frame(width: lato, height: lato)
                .contentShape(forma.sagoma)
        }
        .buttonStyle(StilePremuto())
        .overlay {
            forma.sagoma
                .stroke(forma.colore, lineWidth: 10)
                .frame(width: lato, height: lato)
                .scaleEffect(1 + 0.45 * onda)
                .opacity((1 - onda) * 0.7)
                .allowsHitTesting(false)
        }
        .brightness(accesa ? 0.18 : 0)
        .scaleEffect(accesa ? 1.12 : 1)
        .shadow(color: forma.colore.opacity(accesa ? 0.7 : 0.2), radius: accesa ? 36 : 8, y: 6)
        .animation(.spring(duration: 0.3, bounce: 0.55), value: accesa)
        .onChange(of: accesa) { _, acceso in
            guard acceso else { return }
            onda = 0
            withAnimation(.easeOut(duration: 0.8)) { onda = 1 }
        }
        .accessibilityLabel(forma.nome)
        .accessibilityHint("Tocca per suonare")
    }
}

/// Piccola festa: forme colorate che cadono una volta sola.
struct Coriandoli: View {
    @State private var cadi = false
    private let pezzi = (0..<36).map { _ in
        (x: CGFloat.random(in: 0...1), ritardo: Double.random(in: 0...0.6),
         dimensione: CGFloat.random(in: 18...36), forma: Forma.allCases.randomElement()!)
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(pezzi.indices, id: \.self) { i in
                pezzi[i].forma.sagoma
                    .fill(pezzi[i].forma.colore)
                    .frame(width: pezzi[i].dimensione, height: pezzi[i].dimensione)
                    .rotationEffect(.degrees(cadi ? Double(pezzi[i].x) * 360 : 0))
                    .position(x: pezzi[i].x * geo.size.width, y: cadi ? geo.size.height + 40 : -40)
                    .animation(.easeIn(duration: 2).delay(pezzi[i].ritardo), value: cadi)
            }
        }
        .onAppear { cadi = true }
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { FormeGiocoView(giocatori: [.senzaNome], difficolta: .medio) }
}
