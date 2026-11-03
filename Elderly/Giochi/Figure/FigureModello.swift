import SwiftUI

/// "Ricorda le figure": si guarda una figura, poi la si riconosce tra altre simili.
/// Nessun tempo da rispettare: si passa avanti toccando "Ho guardato". Stesse regole degli altri giochi.
@MainActor @Observable
final class FigureModello {
    enum Fase { case guarda, scegli, trovata }

    let giocatori: [Partecipante]
    private let numeroScelte: Int
    private var figure: [Figura] = []

    private(set) var indice = 0
    private(set) var fase = Fase.guarda
    private(set) var punti: [Int]
    private(set) var scelte: [Figura] = []
    private(set) var sbagliata: Figura?
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        numeroScelte = difficolta.scelteFigure
        punti = Array(repeating: 0, count: giocatori.count)
        ricomincia()
    }

    var totale: Int { figure.count }
    var finito: Bool { indice >= figure.count }
    var turno: Int { indice % giocatori.count }
    var figura: Figura { figure[min(indice, figure.count - 1)] }
    var puntiTotali: Int { punti.reduce(0, +) }

    var testoParlato: String {
        let chi = giocatori.count > 1 && giocatori[turno].haNome ? "Tocca a \(giocatori[turno].nome). " : ""
        return chi + (fase == .guarda ? "Guarda bene la figura, poi tocca il pulsante verde." : "Quale figura hai visto?")
    }

    func hoGuardato() { fase = .scegli }

    func scegli(_ risposta: Figura) {
        guard fase == .scegli else { return }
        // il punto vale solo al primo colpo: dopo una risposta, giusta o no, si mostra la giusta e si va avanti
        if risposta == figura {
            punti[turno] += 1
            Sintetizzatore.condiviso.accordoDiFesta()
        } else {
            sbagliata = risposta
            Sintetizzatore.condiviso.buzz()
        }
        fase = .trovata
        attesa = Task {
            try? await Task.sleep(for: .seconds(Configurazione.pausaDopoRispostaGiusta))
            guard !Task.isCancelled else { return }
            indice += 1
            prepara()
        }
    }

    func ricomincia() {
        attesa?.cancel()
        // ogni figura del CERAD compare almeno una volta, poi si ripetono a caso
        figure = Array((Figura.daRicordare.shuffled() + Figura.daRicordare.shuffled()).prefix(Configurazione.figurePerPartita))
        indice = 0
        punti = Array(repeating: 0, count: giocatori.count)
        prepara()
    }

    func ferma() { attesa?.cancel() }

    private func prepara() {
        guard !finito else { return }
        fase = .guarda
        sbagliata = nil
        scelte = ([figura] + figura.simili.shuffled().prefix(numeroScelte - 1)).shuffled()
    }
}
