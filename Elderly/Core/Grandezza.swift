import SwiftUI

/// Quanto grandi si vedono testi e foto. Si sceglie nelle Opzioni e vale per tutta l'app.
enum Grandezza: String, CaseIterable, Identifiable {
    case piccola, media, grande

    var id: Self { self }

    var nome: String {
        switch self {
        case .piccola: "Piccola"
        case .media: "Media"
        case .grande: "Grande"
        }
    }

    /// Per quanto si moltiplicano i testi (la scala base è già "enorme": la media è quella di sempre).
    var fattoreTesto: CGFloat {
        switch self {
        case .piccola: 0.8
        case .media: 1
        case .grande: 1.2
        }
    }

    /// Quanto spazio prendono le foto, rispetto a tutto lo spazio libero.
    var fattoreFoto: CGFloat {
        switch self {
        case .piccola: 0.65
        case .media: 0.82
        case .grande: 1
        }
    }

    // Dove si salvano le scelte
    static let chiaveTesto = "grandezzaTesto"
    static let chiaveFoto = "grandezzaFoto"
}

/// Dà alle foto la grandezza scelta nelle Opzioni, centrate nello spazio che hanno a disposizione.
private struct ScalaFoto: ViewModifier {
    @AppStorage(Grandezza.chiaveFoto) private var scelta = Grandezza.grande.rawValue

    func body(content: Content) -> some View {
        let fattore = (Grandezza(rawValue: scelta) ?? .grande).fattoreFoto
        GeometryReader { spazio in
            content
                .frame(width: spazio.size.width * fattore, height: spazio.size.height * fattore)
                .position(x: spazio.size.width / 2, y: spazio.size.height / 2)
        }
    }
}

extension View {
    /// Usa tutto lo spazio libero, moltiplicato per la grandezza delle foto scelta nelle Opzioni.
    func grandezzaFoto() -> some View { modifier(ScalaFoto()) }
}
