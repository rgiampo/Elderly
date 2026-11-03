import SwiftUI

struct PuzzleImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Puzzle",
            descrizione: "Metti i pezzi sulla foto, ognuno nel suo posto: trascinali, oppure tocca il pezzo e poi il posto.",
            istruzioni: Istruzioni.puzzle,
            anteprima: { difficolta in
                let griglia = difficolta.grigliaPuzzle
                AnteprimaPuzzle(foto: .risorsa("foto_gatto"), colonne: griglia.colonne, righe: griglia.righe)
                    .aspectRatio(Configurazione.formaFoto, contentMode: .fit)
                    .animation(.spring(duration: 0.4), value: difficolta)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Una foto divisa in \(griglia.colonne * griglia.righe) pezzi")
            },
            partita: { difficolta in
                PuzzleView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}

/// Puzzle a incastro: a sinistra la foto sbiadita con il contorno dei pezzi, a destra il vassoio con i pezzi.
/// Si prende un pezzo, cresce alla sua misura vera, e si lascia sopra il suo posto: se è vicino si incastra.
struct PuzzleView: View {
    @State private var modello: PuzzleModello
    @State private var preso: Int?
    @State private var spostamento: CGSize = .zero
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        _modello = State(initialValue: PuzzleModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    gioco: .puzzle,
                    giocatori: modello.giocatori, punti: [],
                    sommario: modello.totale == 1 ? "Avete completato il puzzle" : "Avete completato \(modello.totale) puzzle",
                    totale: modello.totale, squadra: modello.totale,
                    ricomincia: modello.nuovaPartita, esci: { chiudi() })
            } else {
                partita
            }
            if modello.completato { Coriandoli().allowsHitTesting(false) }
        }
        .conIndietro {
            if !modello.finito {
                // il messaggio sta nella barra in alto: così il tavolo prende quasi tutto lo schermo
                Text(modello.messaggio)
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 12)
                BottoneVoce(testo: Istruzioni.puzzle, etichetta: "Ascolta", altezza: 64)
                BarraGiocatori(giocatori: modello.giocatori)
                Text("\(modello.indice + 1) di \(modello.totale)")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
                    .fixedSize()
            }
        }
        .sensoryFeedback(.success, trigger: modello.completato) { _, nuovo in nuovo }
        .sensoryFeedback(.impact(weight: .medium), trigger: modello.posati.count) { prima, dopo in dopo > prima }
        .onChange(of: modello.messaggio) { _, nuovo in AccessibilityNotification.Announcement(nuovo).post() }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        GeometryReader { spazio in
            tavolo(Misure(spazio: spazio.size, colonne: modello.colonne, righe: modello.righe, pezzi: modello.numeroPezzi))
        }
        .id(modello.indice)   // foto nuova: si ridisegna tutto da capo
        .padding(.horizontal, 28).padding(.bottom, 20)
    }

    private func tavolo(_ m: Misure) -> some View {
        ZStack(alignment: .topLeading) {
            // la foto da ricomporre, sbiadita, con il contorno di ogni pezzo
            FotoView(foto: modello.fotoCorrente)
                .frame(width: m.tavola.width, height: m.tavola.height)
                .opacity(modello.completato ? 1 : 0.28)
                .background(.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .offset(x: m.origineTavola.x, y: m.origineTavola.y)
                .animation(.easeInOut(duration: 0.5), value: modello.completato)
                .accessibilityHidden(true)
            // toccare la foto, con un pezzo scelto, lo mette nel posto toccato
            Color.clear
                .frame(width: m.tavola.width, height: m.tavola.height)
                .contentShape(Rectangle())
                // il tocco va letto prima di spostare la zona: dopo, le coordinate includerebbero lo spostamento
                .onTapGesture { punto in
                    let colonna = min(m.colonne - 1, max(0, Int(punto.x / m.cella.width)))
                    let riga = min(m.righe - 1, max(0, Int(punto.y / m.cella.height)))
                    withAnimation(.spring(duration: 0.4, bounce: 0.25)) { modello.tocca(posto: riga * m.colonne + colonna) }
                }
                .offset(x: m.origineTavola.x, y: m.origineTavola.y)
                .accessibilityHidden(true)
            if !modello.completato {
                ForEach(0..<modello.numeroPezzi, id: \.self) { n in
                    SagomaPezzo(lati: modello.lati[n], margine: m.margine)
                        .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, dash: [10, 6]))
                        .frame(width: m.pezzo.width, height: m.pezzo.height)
                        .position(m.centroSulTavolo(n))
                        .allowsHitTesting(false)
                }
            }

            // i pezzi: prima quelli già posati, poi quelli nel vassoio, e sopra a tutti quello preso
            ForEach(modello.vassoio, id: \.self) { n in
                pezzo(n, m)
                    .zIndex(preso == n ? 2 : (modello.posati.contains(n) ? 0 : 1))
            }
        }
        .frame(width: m.spazio.width, height: m.spazio.height, alignment: .topLeading)
    }

    private func pezzo(_ n: Int, _ m: Misure) -> some View {
        let posato = modello.posati.contains(n)
        let scelto = modello.scelto == n
        let inMano = preso == n || scelto
        let casella = modello.vassoio.firstIndex(of: n) ?? 0
        let centro = posato ? m.centroSulTavolo(n) : m.centroNelVassoio(casella)
        let scala = posato || preso == n ? 1 : (scelto ? m.scalaVassoio * 1.12 : m.scalaVassoio)

        return PezzoPuzzle(foto: modello.fotoCorrente, numero: n, lati: modello.lati[n], misure: m, inMano: inMano, posato: posato,
                           scelto: scelto, completato: modello.completato)
            .scaleEffect(scala)
            .position(x: centro.x + (preso == n ? spostamento.width : 0), y: centro.y + (preso == n ? spostamento.height : 0))
            .animation(inMano ? nil : .spring(duration: 0.4, bounce: 0.25), value: posato)
            .animation(.spring(duration: 0.3), value: inMano)
            .onTapGesture { withAnimation(.spring(duration: 0.3)) { modello.scegli(n) } }
            // basta spostare il dito di poco per trascinare; un tocco senza muoversi sceglie il pezzo
            .gesture(posato ? nil : DragGesture(minimumDistance: 8)
                .onChanged { valore in
                    if preso != n { preso = n }
                    spostamento = valore.translation
                }
                .onEnded { valore in
                    let lasciato = CGPoint(x: centro.x + valore.translation.width, y: centro.y + valore.translation.height)
                    let posto = m.centroSulTavolo(n)
                    // si incastra se lasciato abbastanza vicino al suo posto (metà pezzo): con le dita non serve precisione
                    let vicino = abs(lasciato.x - posto.x) < m.cella.width * 0.5 && abs(lasciato.y - posto.y) < m.cella.height * 0.5
                    withAnimation(.spring(duration: 0.4, bounce: 0.25)) {
                        if vicino { modello.posa(n) }
                        preso = nil
                        spostamento = .zero
                    }
                })
            .allowsHitTesting(!posato && !modello.completato)
            .accessibilityElement()
            .accessibilityLabel(posato ? "Pezzo \(n + 1), al suo posto" : "Pezzo \(n + 1)")
            .accessibilityAction(named: "Metti al suo posto") { withAnimation { modello.posa(n) } }
    }
}

/// Tutte le misure del tavolo: dove sta la foto, quanto è grande un pezzo, dove sono le caselle del vassoio.
private struct Misure {
    let spazio: CGSize
    let colonne: Int
    let righe: Int
    let tavola: CGSize          // la foto da ricomporre, a sinistra e centrata in altezza
    let origineTavola: CGPoint
    let cella: CGSize           // la parte di foto di un pezzo, senza linguette
    let margine: CGFloat        // quanto sporgono le linguette
    let vassoio: CGRect
    let colonneVassoio: Int
    let righeVassoio: Int

    init(spazio: CGSize, colonne: Int, righe: Int, pezzi: Int) {
        self.spazio = spazio
        self.colonne = colonne
        self.righe = righe
        let distanza: CGFloat = 24
        // la foto prende due terzi della larghezza (o tutta l'altezza): il resto è il vassoio, con pezzi abbastanza grandi
        let larghezza = min(spazio.width * 0.66, spazio.height * Configurazione.formaFoto)
        tavola = CGSize(width: larghezza, height: larghezza / Configurazione.formaFoto)
        origineTavola = CGPoint(x: 0, y: (spazio.height - tavola.height) / 2)
        cella = CGSize(width: tavola.width / CGFloat(colonne), height: tavola.height / CGFloat(righe))
        margine = min(cella.width, cella.height) * 0.22
        vassoio = CGRect(x: tavola.width + distanza, y: 0, width: spazio.width - tavola.width - distanza, height: spazio.height)
        colonneVassoio = pezzi > 4 ? 2 : 1
        righeVassoio = (pezzi + colonneVassoio - 1) / colonneVassoio
    }

    /// Il pezzo con le linguette: la cella più il margine su ogni lato.
    var pezzo: CGSize { CGSize(width: cella.width + margine * 2, height: cella.height + margine * 2) }

    func centroSulTavolo(_ n: Int) -> CGPoint {
        CGPoint(x: origineTavola.x + (CGFloat(n % colonne) + 0.5) * cella.width,
                y: origineTavola.y + (CGFloat(n / colonne) + 0.5) * cella.height)
    }

    private var casella: CGSize {
        CGSize(width: vassoio.width / CGFloat(colonneVassoio), height: vassoio.height / CGFloat(righeVassoio))
    }

    func centroNelVassoio(_ posizione: Int) -> CGPoint {
        CGPoint(x: vassoio.minX + (CGFloat(posizione % colonneVassoio) + 0.5) * casella.width,
                y: vassoio.minY + (CGFloat(posizione / colonneVassoio) + 0.5) * casella.height)
    }

    /// Nel vassoio i pezzi sono più piccoli, perché ci stiano tutti; presi in mano tornano alla misura vera.
    var scalaVassoio: CGFloat { min(1, casella.width / pezzo.width, casella.height / pezzo.height) * 0.92 }
}

/// Un pezzo: la parte giusta della foto ritagliata con la sagoma a incastro, con un bordo bianco e l'ombra.
private struct PezzoPuzzle: View {
    let foto: FotoQuiz
    let numero: Int
    let lati: PuzzleModello.Lati
    let misure: Misure
    let inMano: Bool
    let posato: Bool
    let scelto: Bool
    let completato: Bool

    var body: some View {
        let sagoma = SagomaPezzo(lati: lati, margine: misure.margine)
        let origine = CGPoint(x: CGFloat(numero % misure.colonne) * misure.cella.width - misure.margine,
                              y: CGFloat(numero / misure.colonne) * misure.cella.height - misure.margine)
        Color.clear
            .frame(width: misure.pezzo.width, height: misure.pezzo.height)
            .overlay(alignment: .topLeading) {
                FotoView(foto: foto)
                    .frame(width: misure.tavola.width, height: misure.tavola.height)
                    .offset(x: -origine.x, y: -origine.y)
            }
            .clipShape(sagoma)
            // il pezzo scelto con un tocco ha il bordo blu spesso (non solo il colore: è anche più grande e sollevato)
            .overlay { sagoma.stroke(scelto ? Tema.blu : .white, lineWidth: completato ? 0 : (scelto ? 9 : 3)) }
            .contentShape(sagoma)
            .shadow(color: Tema.testo.opacity(posato ? 0 : (inMano ? 0.5 : 0.3)), radius: inMano ? 18 : 6, y: inMano ? 10 : 3)
    }
}

/// La sagoma classica del puzzle: un rettangolo con, su ogni lato, una linguetta in fuori, un incavo o niente.
private struct SagomaPezzo: Shape {
    let lati: PuzzleModello.Lati
    let margine: CGFloat

    func path(in rect: CGRect) -> Path {
        let k = margine
        let a = CGPoint(x: rect.minX + k, y: rect.minY + k), b = CGPoint(x: rect.maxX - k, y: rect.minY + k)
        let c = CGPoint(x: rect.maxX - k, y: rect.maxY - k), d = CGPoint(x: rect.minX + k, y: rect.maxY - k)
        var p = Path()
        p.move(to: a)
        lato(&p, da: a, a: b, fuori: CGVector(dx: 0, dy: -1), verso: lati.sopra)
        lato(&p, da: b, a: c, fuori: CGVector(dx: 1, dy: 0), verso: lati.destra)
        lato(&p, da: c, a: d, fuori: CGVector(dx: 0, dy: 1), verso: lati.sotto)
        lato(&p, da: d, a: a, fuori: CGVector(dx: -1, dy: 0), verso: lati.sinistra)
        p.closeSubpath()
        return p
    }

    /// Un lato da `da` ad `a`: dritto, oppure con la linguetta tonda al centro (in fuori o in dentro).
    private func lato(_ p: inout Path, da: CGPoint, a: CGPoint, fuori: CGVector, verso: CGFloat) {
        guard verso != 0 else { p.addLine(to: a); return }
        let lunghezza = hypot(a.x - da.x, a.y - da.y)
        let dir = CGVector(dx: (a.x - da.x) / lunghezza, dy: (a.y - da.y) / lunghezza)
        // un punto lungo il lato (t da 0 a 1) e spostato in fuori di `o`
        func punto(_ t: CGFloat, _ o: CGFloat) -> CGPoint {
            CGPoint(x: da.x + dir.dx * t * lunghezza + fuori.dx * o * verso * margine,
                    y: da.y + dir.dy * t * lunghezza + fuori.dy * o * verso * margine)
        }
        // la larghezza della linguetta non supera il margine, così resta tonda anche sui lati corti
        let mezza = min(0.13, margine * 0.75 / lunghezza)
        p.addLine(to: punto(0.5 - mezza, 0))
        p.addCurve(to: punto(0.5 + mezza, 0), control1: punto(0.5 - mezza * 2.2, 1.3), control2: punto(0.5 + mezza * 2.2, 1.3))
        p.addLine(to: a)
    }
}

/// Anteprima: la foto divisa dalle righe bianche dei pezzi, per far capire il gioco a colpo d'occhio.
struct AnteprimaPuzzle: View {
    let foto: FotoQuiz
    let colonne: Int
    let righe: Int

    var body: some View {
        FotoView(foto: foto)
            .overlay {
                GeometryReader { spazio in
                    Path { linee in
                        for c in 1..<colonne {
                            let x = spazio.size.width * CGFloat(c) / CGFloat(colonne)
                            linee.move(to: CGPoint(x: x, y: 0)); linee.addLine(to: CGPoint(x: x, y: spazio.size.height))
                        }
                        for r in 1..<righe {
                            let y = spazio.size.height * CGFloat(r) / CGFloat(righe)
                            linee.move(to: CGPoint(x: 0, y: y)); linee.addLine(to: CGPoint(x: spazio.size.width, y: y))
                        }
                    }
                    .stroke(.white, lineWidth: 6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
