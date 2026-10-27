import Foundation

/// Una melodia conosciuta, scritta con le 5 forme (do, re, mi, fa, sol): 0 = cerchio, 1 = quadrato, 2 = triangolo, 3 = stella, 4 = cuore.
/// Il gioco la fa riascoltare un pezzo alla volta: ogni giro si aggiunge una nota, finché si suona tutta.
struct Melodia {
    let titolo: String
    let note: [Int]

    /// Le melodie disponibili per un livello: usano solo le forme che ci sono.
    static func perLivello(_ formeDisponibili: Int) -> [Melodia] {
        tutte.filter { ($0.note.max() ?? 0) < formeDisponibili }
    }

    static let tutte: [Melodia] = [
        Melodia(titolo: "Fra Martino", note: [0, 1, 2, 0, 0, 1, 2, 0]),
        Melodia(titolo: "Su e giù per la scala", note: [0, 1, 2, 3, 2, 1, 0, 2, 3, 2, 1, 0]),
        Melodia(titolo: "Fra Martino, la seconda parte", note: [2, 3, 4, 2, 3, 4, 4, 5 - 1, 3, 2, 0].map { min($0, 4) }),
        Melodia(titolo: "Inno alla gioia", note: [2, 2, 3, 4, 4, 3, 2, 1, 0, 0, 1, 2, 2, 1, 1]),
    ]
}
