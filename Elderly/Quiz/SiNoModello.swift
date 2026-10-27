import SwiftUI

/// Il gioco "Sì o no": una foto e un nome, e si dice se il nome è quello giusto.
/// Stesse regole degli altri giochi: nessuna sconfitta e turni se si gioca in due.
@MainActor @Observable
final class SiNoModello {
    /// Una domanda: la foto, il nome proposto, e se il nome è quello giusto.
    struct Quesito: Identifiable {
        let id = UUID()
        let foto: FotoQuiz?
        let nome: String
        let èGiusto: Bool
    }

    private let quiz: Quiz
    let giocatori: [Partecipante]

    private(set) var quesiti: [Quesito] = []
    private(set) var indice = 0
    private(set) var punti: [Int]
    private(set) var messaggio = ""
    private(set) var rispostaData: Bool?   // cosa ha toccato chi gioca (sì = true), finché si aspetta la domanda dopo

    private var attesa: Task<Void, Never>?

    init(quiz: Quiz, giocatori: [Partecipante]) {
        self.quiz = quiz
        self.giocatori = giocatori
        punti = Array(repeating: 0, count: giocatori.count)
        iniziaPartita()
    }

    var totale: Int { quesiti.count }
    var finito: Bool { indice >= quesiti.count }
    var turno: Int { indice % giocatori.count }
    var quesito: Quesito { quesiti[min(indice, quesiti.count - 1)] }
    var puntiTotali: Int { punti.reduce(0, +) }
    var inAttesa: Bool { rispostaData != nil }

    var testoParlato: String {
        var testo = giocatori.count > 1 && giocatori[turno].haNome ? "Tocca a \(giocatori[turno].nome). " : ""
        return testo + "Nella foto c'è: \(quesito.nome)?"
    }

    func rispondi(sì: Bool) {
        guard !inAttesa else { return }
        rispostaData = sì
        if sì == quesito.èGiusto {
            punti[turno] += 1
            messaggio = "Giusto!"
            Sintetizzatore.condiviso.accordoDiFesta()
        } else {
            // nessuna penalità: si dice com'era e si va avanti
            messaggio = quesito.èGiusto ? "Era proprio così: sì!" : "No, qui c'era un'altra cosa."
        }
        attesa = Task {
            try? await Task.sleep(for: .seconds(Configurazione.pausaDopoRispostaGiusta))
            guard !Task.isCancelled else { return }
            indice += 1
            rispostaData = nil
            messaggio = ""
        }
    }

    func ricomincia() {
        attesa?.cancel()
        iniziaPartita()
    }

    func ferma() { attesa?.cancel() }

    /// Per ogni domanda del quiz, mezza volta si mostra la foto giusta (sì) e mezza una sbagliata con il nome giusto (no).
    private func iniziaPartita() {
        quesiti = quiz.domandeDellaPartita().compactMap { domanda in
            guard let giusta = domanda.rispostaGiusta,
                  let sbagliata = domanda.risposte.first(where: { !$0.giusta }) else { return nil }
            return Bool.random()
                ? Quesito(foto: giusta.foto, nome: giusta.testo, èGiusto: true)
                : Quesito(foto: sbagliata.foto, nome: giusta.testo, èGiusto: false)
        }
        indice = 0
        punti = Array(repeating: 0, count: giocatori.count)
        rispostaData = nil
        messaggio = ""
    }
}
