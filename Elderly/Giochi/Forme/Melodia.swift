import Foundation

/// Una melodia conosciuta, scritta con le 12 forme del livello Maestro (0 = do, 1 = re, 2 = mi, 3 = fa, 4 = sol, 5 = la, 6 = si, 7 = do alto…).
/// Il gioco la fa riascoltare un pezzo alla volta: ogni giro si aggiunge una nota, finché si suona tutta.
struct Melodia {
    let titolo: String
    let note: [Int]

    /// Dalla più semplice alla più lunga.
    static let tutte: [Melodia] = [
        Melodia(titolo: "Fra Martino", note: [0, 1, 2, 0, 0, 1, 2, 0, 2, 3, 4, 2, 3, 4]),
        Melodia(titolo: "Brilla, brilla, piccola stella", note: [0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0]),
        Melodia(titolo: "Nella vecchia fattoria", note: [0, 0, 0, 4, 5, 5, 4, 2, 2, 1, 1, 0]),
        Melodia(titolo: "Jingle bells", note: [2, 2, 2, 2, 2, 2, 2, 4, 0, 1, 2]),
        Melodia(titolo: "Inno alla gioia", note: [2, 2, 3, 4, 4, 3, 2, 1, 0, 0, 1, 2, 2, 1, 1]),
        Melodia(titolo: "Su e giù per la scala", note: [0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0]),
    ]
}
