import SwiftUI

/// Una carta del gioco delle coppie: due carte con lo stesso `coppia` formano una coppia.
struct Carta: Identifiable {
    let id = UUID()
    let coppia: Int
    let foto: FotoQuiz
    var scoperta = false
    var trovata = false
}

/// Le regole delle coppie: si girano due carte; se sono uguali restano scoperte e si continua,
/// altrimenti si rigirano e tocca all'altra persona. Nessuna sconfitta, nessun tempo.
@MainActor @Observable
final class CoppieModello {
    let giocatori: [Partecipante]
    private let numeroCoppie: Int

    private(set) var carte: [Carta] = []
    private(set) var turno = 0
    private(set) var punti: [Int]
    private(set) var messaggio = ""
    private var bloccato = false
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        numeroCoppie = difficolta.numeroCoppie
        punti = Array(repeating: 0, count: giocatori.count)
        nuovaPartita()
    }

    var finito: Bool { !carte.isEmpty && carte.allSatisfy(\.trovata) }
    var colonne: Int { carte.count > 8 ? 4 : max(carte.count / 2, 1) }
    var righe: Int { (carte.count + colonne - 1) / colonne }
    var puntiTotali: Int { punti.reduce(0, +) }

    func tocca(_ carta: Carta) {
        guard !bloccato, let i = carte.firstIndex(where: { $0.id == carta.id }),
              !carte[i].scoperta, !carte[i].trovata else { return }
        carte[i].scoperta = true
        Sintetizzatore.condiviso.suona(659.25, volume: 0.35)

        let scoperte = carte.indices.filter { carte[$0].scoperta }
        guard scoperte.count == 2 else { return }

        if carte[scoperte[0]].coppia == carte[scoperte[1]].coppia {
            scoperte.forEach { carte[$0].trovata = true; carte[$0].scoperta = false }
            punti[turno] += 1
            messaggio = finito ? "" : "Una coppia!"
            Sintetizzatore.condiviso.accordoDiFesta()
        } else {
            bloccato = true
            messaggio = "Sono diverse"
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaCarteDiverse))
                guard !Task.isCancelled else { return }
                scoperte.forEach { carte[$0].scoperta = false }
                turno = (turno + 1) % giocatori.count
                messaggio = ""
                bloccato = false
            }
        }
    }

    func ricomincia() {
        attesa?.cancel()
        nuovaPartita()
    }

    func ferma() { attesa?.cancel() }

    /// Sceglie a caso le foto tra quelle dei quiz, le raddoppia e le mescola.
    private func nuovaPartita() {
        let foto = CatalogoQuiz.fotoDellApp().shuffled().prefix(numeroCoppie)
        carte = foto.enumerated().flatMap { numero, foto in
            [Carta(coppia: numero, foto: foto), Carta(coppia: numero, foto: foto)]
        }.shuffled()
        turno = 0
        punti = Array(repeating: 0, count: giocatori.count)
        messaggio = ""
        bloccato = false
    }
}
