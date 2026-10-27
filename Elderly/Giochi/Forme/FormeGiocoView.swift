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
                    Text(partita.titoloMelodia.map { "Melodia: \($0)" } ?? "Sequenza più lunga insieme: \(partita.record)")
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
        .coloreSfondoDelTurno(giocatori, turno: partita.giocatoreCorrente)
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
            // più di cinque forme vanno su più righe: restano grandi
            let righe = partita.forme.count > 8 ? 3 : (partita.forme.count > 5 ? 2 : 1)
            let perRiga = (partita.forme.count + righe - 1) / righe
            let distanza: CGFloat = 32
            // 0.88: la forma illuminata cresce un po' e non deve uscire dallo schermo
            let lato = min((spazio.size.height - distanza * CGFloat(righe - 1)) / CGFloat(righe),
                           (spazio.size.width - distanza * CGFloat(perRiga - 1)) / CGFloat(perRiga)) * 0.88
            VStack(spacing: distanza) {
                ForEach(0..<righe, id: \.self) { r in
                    HStack(spacing: distanza) {
                        ForEach(Array(partita.forme.dropFirst(r * perRiga).prefix(perRiga))) { forma in
                            FormaBottone(forma: forma, accesa: partita.formaAccesa == forma, lato: lato) {
                                partita.tocca(forma)
                            }
                        }
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

/// Piccola festa: forme colorate che cadono dall'alto una volta sola, dondolando e ruotando.
struct Coriandoli: View {
    private struct Pezzo {
        let x = CGFloat.random(in: 0.03...0.97)
        let ritardo = Double.random(in: 0...0.8)
        let durata = Double.random(in: 2.2...3.4)
        let lato = CGFloat.random(in: 24...46)
        let dondolio = Double.random(in: 0.8...1.6)
        let ampiezza = CGFloat.random(in: 14...40)
        let giri = Double.random(in: -300...300)         // gradi al secondo
        let forma = Forma.allCases.randomElement()!
    }

    // @State: i valori a caso si scelgono una volta sola (con `let` cambiavano a ogni ridisegno e i pezzi saltavano)
    @State private var pezzi = (0..<40).map { _ in Pezzo() }
    @State private var inizio = Date()

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { contesto in
                let t = contesto.date.timeIntervalSince(inizio)
                ZStack {
                    ForEach(pezzi.indices, id: \.self) { i in
                        let p = pezzi[i]
                        let avanzamento = (t - p.ritardo) / p.durata
                        if avanzamento >= 0, avanzamento <= 1 {
                            p.forma.sagoma
                                .fill(p.forma.colore)
                                .frame(width: p.lato, height: p.lato)
                                .rotationEffect(.degrees(p.giri * t))
                                .position(x: p.x * geo.size.width + p.ampiezza * CGFloat(sin(t * p.dondolio * 3)),
                                          y: -50 + (geo.size.height + 100) * CGFloat(avanzamento))
                                .opacity(avanzamento > 0.85 ? (1 - avanzamento) / 0.15 : 1)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
