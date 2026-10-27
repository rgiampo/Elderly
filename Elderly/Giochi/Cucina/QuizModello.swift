import SwiftUI

/// Regole del quiz: nessuna sconfitta. Se sbagli puoi riprovare; la risposta giusta si mostra sempre.
@MainActor @Observable
final class QuizModello {
    private let domande = DomandeCucina.tutte.shuffled()

    private(set) var indice = 0
    private(set) var punti = 0
    private(set) var risposte: [Risposta] = []
    private(set) var sbagliate: Set<UUID> = []   // risposte già provate e non giuste
    private(set) var rivelata: UUID?             // la risposta giusta, quando si è trovata
    private(set) var messaggio = ""

    private var errori = 0
    private var compito: Task<Void, Never>?

    var totale: Int { domande.count }
    var finito: Bool { indice >= domande.count }
    var domanda: DomandaQuiz { domande[min(indice, domande.count - 1)] }

    /// Testo per la voce: la domanda e le risposte possibili.
    var testoParlato: String {
        domanda.testo + " Le risposte sono: " + risposte.map(\.testo).joined(separator: ", oppure ")
    }

    init() { caricaDomanda() }

    func scegli(_ risposta: Risposta) {
        guard rivelata == nil, !sbagliate.contains(risposta.id) else { return }

        if risposta.giusta {
            if errori == 0 { punti += 1 } // il punto vale solo al primo tentativo
            rivelata = risposta.id
            messaggio = "Giusto!"
            Sintetizzatore.condiviso.accordoDiFesta()
            vaiAvanti(dopo: 2)
        } else {
            errori += 1
            sbagliate.insert(risposta.id)
            messaggio = "Non è questa. Riprova!"
        }
    }

    func ricomincia() {
        compito?.cancel()
        self.indice = 0
        self.punti = 0
        caricaDomanda()
    }

    func ferma() { compito?.cancel() }

    private func caricaDomanda() {
        guard !finito else { return }
        risposte = domande[indice].risposte.shuffled()
        sbagliate = []
        rivelata = nil
        errori = 0
        messaggio = ""
    }

    private func vaiAvanti(dopo secondi: Double) {
        compito = Task {
            try? await Task.sleep(for: .seconds(secondi))
            guard !Task.isCancelled else { return }
            indice += 1
            caricaDomanda()
        }
    }
}
