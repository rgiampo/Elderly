import SwiftUI

/// Puzzle a incastro: la foto è divisa in pezzi con le linguette; si trascinano dal vassoio al loro posto.
/// Nessun timer e nessun errore: un pezzo lasciato nel posto sbagliato torna nel vassoio.
@MainActor @Observable
final class PuzzleModello {
    /// I quattro lati di un pezzo: 0 = dritto (bordo della foto), 1 = linguetta in fuori, -1 = incavo.
    struct Lati { var sopra: CGFloat = 0, destra: CGFloat = 0, sotto: CGFloat = 0, sinistra: CGFloat = 0 }

    let giocatori: [Partecipante]
    let colonne: Int
    let righe: Int
    private var foto: [FotoQuiz] = []

    private(set) var indice = 0
    private(set) var lati: [Lati] = []
    private(set) var posati: Set<Int> = []
    /// L'ordine dei pezzi nel vassoio: `vassoio[n]` è il pezzo nella casella n.
    private(set) var vassoio: [Int] = []
    private(set) var completato = false
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        (colonne, righe) = difficolta.grigliaPuzzle
        nuovaPartita()
    }

    var numeroPezzi: Int { colonne * righe }
    var totale: Int { foto.count }
    var finito: Bool { indice >= foto.count }
    var fotoCorrente: FotoQuiz { foto[min(indice, foto.count - 1)] }

    var messaggio: String {
        if completato { return "Bravi, è completo!" }
        return posati.isEmpty ? "Trascina i pezzi sulla foto" : "Pezzi al loro posto: \(posati.count) su \(numeroPezzi)"
    }

    /// Il pezzo è arrivato al suo posto: resta lì.
    func posa(_ pezzo: Int) {
        guard !completato, !posati.contains(pezzo) else { return }
        posati.insert(pezzo)
        Sintetizzatore.condiviso.suona(Forma.cuore.frequenza, volume: 0.5)
        if posati.count == numeroPezzi { finisci() }
    }

    func ferma() { attesa?.cancel() }

    func nuovaPartita() {
        attesa?.cancel()
        foto = Array(CatalogoQuiz.fotoDellApp().shuffled().prefix(Configurazione.fotoPerPartitaPuzzle))
        indice = 0
        prepara()
    }

    private func finisci() {
        completato = true
        Sintetizzatore.condiviso.accordoDiFesta()
        attesa = Task {
            try? await Task.sleep(for: .seconds(Configurazione.pausaPuzzle))
            guard !Task.isCancelled else { return }
            indice += 1
            if !finito { prepara() }
        }
    }

    /// Lati a incastro casuali: dove due pezzi si toccano, uno ha la linguetta e l'altro l'incavo.
    private func prepara() {
        completato = false
        posati = []
        var nuovi = Array(repeating: Lati(), count: numeroPezzi)
        for riga in 0..<righe {
            for colonna in 0..<colonne {
                let n = riga * colonne + colonna
                if colonna + 1 < colonne {
                    let verso: CGFloat = Bool.random() ? 1 : -1
                    nuovi[n].destra = verso
                    nuovi[n + 1].sinistra = -verso
                }
                if riga + 1 < righe {
                    let verso: CGFloat = Bool.random() ? 1 : -1
                    nuovi[n].sotto = verso
                    nuovi[n + colonne].sopra = -verso
                }
            }
        }
        lati = nuovi
        vassoio = Array(0..<numeroPezzi).shuffled()
    }
}
