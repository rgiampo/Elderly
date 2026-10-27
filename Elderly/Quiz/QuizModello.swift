import SwiftUI

/// Le regole del quiz. Nessuna sconfitta: se sbagli puoi riprovare, e il punto va a chi aveva il turno.
/// Con due giocatori le domande passano da uno all'altro.
@MainActor @Observable
final class QuizModello {
    private let quiz: Quiz
    let giocatori: [Partecipante]

    private(set) var domande: [DomandaQuiz] = []
    private(set) var indice = 0
    private(set) var punti: [Int]
    private(set) var sbagliate: Set<UUID> = []       // risposte già provate e non giuste
    private(set) var rivelata: UUID?                 // la risposta giusta, dopo averla trovata
    private(set) var messaggio = ""

    private var errori = 0
    private var attesa: Task<Void, Never>?

    init(quiz: Quiz, giocatori: [Partecipante]) {
        self.quiz = quiz
        self.giocatori = giocatori
        punti = Array(repeating: 0, count: giocatori.count)
        iniziaPartita()
    }

    var totale: Int { domande.count }
    var finito: Bool { indice >= domande.count }
    var turno: Int { indice % giocatori.count }
    var domanda: DomandaQuiz { domande[min(indice, domande.count - 1)] }
    var risposte: [RispostaQuiz] { domanda.risposte }
    var puntiTotali: Int { punti.reduce(0, +) }

    /// Il testo che la voce legge: di chi è il turno, la domanda e le risposte.
    var testoParlato: String {
        var testo = giocatori.count > 1 && giocatori[turno].haNome ? "Tocca a \(giocatori[turno].nome). " : ""
        testo += domanda.testo + " Le risposte sono: " + risposte.map(\.testo).joined(separator: ", oppure ")
        return testo
    }

    func scegli(_ risposta: RispostaQuiz) {
        guard rivelata == nil, !sbagliate.contains(risposta.id) else { return }

        if risposta.giusta {
            if errori == 0 { punti[turno] += 1 } // il punto vale solo al primo tentativo
            rivelata = risposta.id
            messaggio = "Giusto!"
            Sintetizzatore.condiviso.accordoDiFesta()
            vaiAvanti()
        } else {
            errori += 1
            sbagliate.insert(risposta.id)
            messaggio = "Non è questa. Riprova!"
        }
    }

    func ricomincia() {
        attesa?.cancel()
        iniziaPartita()
    }

    func ferma() { attesa?.cancel() }

    // MARK: - Passi

    private func iniziaPartita() {
        domande = quiz.domandeDellaPartita()
        indice = 0
        punti = Array(repeating: 0, count: giocatori.count)
        reimposta()
    }

    private func reimposta() {
        sbagliate = []
        rivelata = nil
        errori = 0
        messaggio = ""
    }

    private func vaiAvanti() {
        attesa = Task {
            try? await Task.sleep(for: .seconds(Configurazione.pausaDopoRispostaGiusta))
            guard !Task.isCancelled else { return }
            indice += 1
            reimposta()
        }
    }
}
