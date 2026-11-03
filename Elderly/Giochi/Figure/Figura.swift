import SwiftUI

/// Le figure da ricordare, ispirate alla prova "prassia costruttiva" del CERAD: cerchio, rombo,
/// due rettangoli sovrapposti e cubo. Le altre sono figure simili che fanno da distrattori.
/// Si disegnano solo a contorno, come un disegno a penna.
enum Figura: Shape, CaseIterable {
    case cerchio, ellisse, ottagono
    case rombo, quadrato, romboSchiacciato, parallelogramma
    case rettangoliSovrapposti, rettangoliSeparati, rettangoliACroce, rettangoliUnoDentro
    case cubo, cuboSenzaSpigolo, dueQuadrati, esagono

    /// Le quattro figure del CERAD: sono quelle da ricordare.
    static let daRicordare: [Figura] = [.cerchio, .rombo, .rettangoliSovrapposti, .cubo]

    /// Le figure che assomigliano a quella da ricordare.
    var simili: [Figura] {
        switch self {
        case .cerchio: [.ellisse, .ottagono, .esagono]
        case .rombo: [.quadrato, .romboSchiacciato, .parallelogramma]
        case .rettangoliSovrapposti: [.rettangoliSeparati, .rettangoliACroce, .rettangoliUnoDentro]
        case .cubo: [.cuboSenzaSpigolo, .dueQuadrati, .esagono]
        default: []
        }
    }

    /// Per la voce e per chi usa VoiceOver.
    var nome: String {
        switch self {
        case .cerchio: "cerchio"
        case .ellisse: "ellisse"
        case .ottagono: "ottagono"
        case .rombo: "rombo"
        case .quadrato: "quadrato"
        case .romboSchiacciato: "rombo schiacciato"
        case .parallelogramma: "figura storta"
        case .rettangoliSovrapposti: "due rettangoli sovrapposti"
        case .rettangoliSeparati: "due rettangoli separati"
        case .rettangoliACroce: "due rettangoli a croce"
        case .rettangoliUnoDentro: "un rettangolo dentro l'altro"
        case .cubo: "cubo"
        case .cuboSenzaSpigolo: "cubo senza uno spigolo"
        case .dueQuadrati: "due quadrati"
        case .esagono: "esagono"
        }
    }

    /// I punti sono in un quadrato da 0 a 1, centrato nello spazio disponibile.
    func path(in rect: CGRect) -> Path {
        let lato = min(rect.width, rect.height)
        let origine = CGPoint(x: rect.midX - lato / 2, y: rect.midY - lato / 2)
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: origine.x + x * lato, y: origine.y + y * lato) }
        func r(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> CGRect {
            CGRect(origin: p(x1, y1), size: CGSize(width: (x2 - x1) * lato, height: (y2 - y1) * lato))
        }
        func poligono(_ punti: [CGPoint]) -> Path { Path { $0.addLines(punti); $0.closeSubpath() } }
        func regolare(_ lati: Int) -> Path {
            poligono((0..<lati).map { i in
                let angolo = Double(i) / Double(lati) * 2 * .pi + .pi / Double(lati)
                return p(0.5 + 0.42 * cos(angolo), 0.5 + 0.42 * sin(angolo))
            })
        }
        // fronte e retro del cubo
        let fronte = r(0.08, 0.37, 0.63, 0.92), retro = r(0.37, 0.08, 0.92, 0.63)

        switch self {
        case .cerchio: return Path(ellipseIn: r(0.08, 0.08, 0.92, 0.92))
        case .ellisse: return Path(ellipseIn: r(0.04, 0.24, 0.96, 0.76))
        case .ottagono: return regolare(8)
        case .esagono: return regolare(6)
        case .rombo: return poligono([p(0.5, 0.05), p(0.85, 0.5), p(0.5, 0.95), p(0.15, 0.5)])
        case .quadrato: return Path(r(0.15, 0.15, 0.85, 0.85))
        case .romboSchiacciato: return poligono([p(0.5, 0.27), p(0.96, 0.5), p(0.5, 0.73), p(0.04, 0.5)])
        case .parallelogramma: return poligono([p(0.3, 0.25), p(0.96, 0.25), p(0.7, 0.75), p(0.04, 0.75)])
        case .rettangoliSovrapposti:
            return Path { $0.addRect(r(0.04, 0.22, 0.62, 0.6)); $0.addRect(r(0.38, 0.4, 0.96, 0.78)) }
        case .rettangoliSeparati:
            return Path { $0.addRect(r(0.03, 0.22, 0.45, 0.6)); $0.addRect(r(0.55, 0.4, 0.97, 0.78)) }
        case .rettangoliACroce:
            return Path { $0.addRect(r(0.06, 0.36, 0.94, 0.64)); $0.addRect(r(0.36, 0.06, 0.64, 0.94)) }
        case .rettangoliUnoDentro:
            return Path { $0.addRect(r(0.04, 0.18, 0.96, 0.82)); $0.addRect(r(0.26, 0.36, 0.74, 0.64)) }
        case .cubo, .cuboSenzaSpigolo:
            return Path { percorso in
                percorso.addRect(fronte)
                percorso.addLines([CGPoint(x: fronte.minX, y: fronte.minY), CGPoint(x: retro.minX, y: retro.minY),
                                   CGPoint(x: retro.maxX, y: retro.minY), CGPoint(x: retro.maxX, y: retro.maxY),
                                   CGPoint(x: fronte.maxX, y: fronte.maxY)])
                if self == .cubo {
                    percorso.move(to: CGPoint(x: fronte.maxX, y: fronte.minY))
                    percorso.addLine(to: CGPoint(x: retro.maxX, y: retro.minY))
                }
            }
        case .dueQuadrati:
            return Path { $0.addRect(fronte); $0.addRect(retro) }
        }
    }
}

extension Figura {
    /// La figura disegnata a penna: contorno spesso, angoli arrotondati.
    func disegno(spessore: CGFloat, colore: Color = Tema.testo) -> some View {
        stroke(colore, style: StrokeStyle(lineWidth: spessore, lineCap: .round, lineJoin: .round))
            .aspectRatio(1, contentMode: .fit)
    }
}
