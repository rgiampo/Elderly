import SwiftUI

/// "Cosa manca?": si guardano alcune foto, poi una sparisce e bisogna riconoscere quale era.
/// Nessun tempo da rispettare: si passa avanti toccando "Ho guardato". Stesse regole degli altri giochi.
@MainActor @Observable
final class CosaMancaModello {
    enum Fase { case guarda, scegli, trovata }

    let giocatori: [Partecipante]
    private let quante: Int

    private(set) var indice = 0
    private(set) var fase = Fase.guarda
    private(set) var punti: [Int]
    private(set) var foto: [FotoQuiz] = []          // le foto mostrate
    private(set) var posizioneMancante = 0           // quale è sparita
    private(set) var scelte: [FotoQuiz] = []         // la sparita e una che non c'entra, mescolate
    private(set) var sbagliate: Set<FotoQuiz> = []
    private var errori = 0
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        quante = difficolta.fotoCosaManca
        punti = Array(repeating: 0, count: giocatori.count)
        nuovoRound()
    }

    var totale: Int { Configurazione.turniCosaManca }
    var finito: Bool { indice >= totale }
    var turno: Int { indice % giocatori.count }
    var mancante: FotoQuiz { foto[posizioneMancante] }
    var puntiTotali: Int { punti.reduce(0, +) }

    var testoParlato: String {
        let chi = giocatori.count > 1 && giocatori[turno].haNome ? "Tocca a \(giocatori[turno].nome). " : ""
        return chi + (fase == .guarda ? "Guarda bene le foto, poi tocca il pulsante verde." : "Quale foto è sparita?")
    }

    func hoGuardato() { fase = .scegli }

    func scegli(_ risposta: FotoQuiz) {
        guard fase == .scegli, !sbagliate.contains(risposta) else { return }
        if risposta == mancante {
            if errori == 0 { punti[turno] += 1 }
            fase = .trovata
            Sintetizzatore.condiviso.accordoDiFesta()
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaDopoRispostaGiusta))
                guard !Task.isCancelled else { return }
                indice += 1
                nuovoRound()
            }
        } else {
            // sbagliato: buzz, si vede la foto che mancava e si va avanti da soli
            errori += 1
            sbagliate.insert(risposta)
            fase = .trovata
            Sintetizzatore.condiviso.buzz()
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaDopoRispostaGiusta))
                guard !Task.isCancelled else { return }
                indice += 1
                nuovoRound()
            }
        }
    }

    func ricomincia() {
        attesa?.cancel()
        indice = 0
        punti = Array(repeating: 0, count: giocatori.count)
        nuovoRound()
    }

    func ferma() { attesa?.cancel() }

    private func nuovoRound() {
        guard !finito else { return }
        let tutte = CatalogoQuiz.fotoDellApp().shuffled()
        foto = Array(tutte.prefix(quante))
        posizioneMancante = Int.random(in: 0..<foto.count)
        let intrusa = tutte[quante]
        scelte = [foto[posizioneMancante], intrusa].shuffled()
        sbagliate = []; errori = 0
        fase = .guarda
    }
}
