import Foundation

/// Il quiz mentre lo si sta scrivendo. Sono semplici valori: si controllano e si provano facilmente,
/// e solo alla fine diventano un `QuizCreato` salvato.
struct BozzaRisposta: Identifiable {
    let id = UUID()
    var testo = ""
    var foto: Data?
}

struct BozzaDomanda: Identifiable {
    let id = UUID()
    var testo = ""
    var risposte = [BozzaRisposta(), BozzaRisposta()]
    var indiceGiusta = 0
}

struct BozzaQuiz {
    var titolo = ""
    var domande = [BozzaDomanda()]

    /// Cosa manca per poter salvare, oppure `nil` se è tutto a posto.
    var problema: String? {
        if titolo.trimmingCharacters(in: .whitespaces).isEmpty { return "Scrivi il titolo del quiz." }
        for (numero, domanda) in domande.enumerated() {
            let nome = "Domanda \(numero + 1)"
            if domanda.testo.trimmingCharacters(in: .whitespaces).isEmpty { return "\(nome): scrivi la domanda." }
            if domanda.risposte.count < Configurazione.risposteMinime { return "\(nome): servono almeno \(Configurazione.risposteMinime) risposte." }
            if domanda.risposte.contains(where: { $0.foto == nil }) { return "\(nome): scegli una foto per ogni risposta." }
            if domanda.risposte.contains(where: { $0.testo.trimmingCharacters(in: .whitespaces).isEmpty }) { return "\(nome): scrivi il nome sotto ogni foto." }
        }
        return nil
    }
}

extension BozzaQuiz {
    init(_ quiz: QuizCreato) {
        titolo = quiz.titolo
        domande = quiz.domande.sorted { $0.posizione < $1.posizione }.map { domanda in
            let risposte = domanda.risposte.sorted { $0.posizione < $1.posizione }
            var bozza = BozzaDomanda()
            bozza.testo = domanda.testo
            bozza.risposte = risposte.map { BozzaRisposta(testo: $0.testo, foto: $0.foto) }
            bozza.indiceGiusta = risposte.firstIndex(where: \.giusta) ?? 0
            return bozza
        }
    }

    /// Trasforma la bozza nelle domande da salvare.
    func comeDomande() -> [DomandaCreata] {
        domande.enumerated().map { posizione, domanda in
            let creata = DomandaCreata(posizione: posizione, testo: domanda.testo.trimmingCharacters(in: .whitespaces))
            creata.risposte = domanda.risposte.enumerated().map { numero, risposta in
                RispostaCreata(posizione: numero, testo: risposta.testo.trimmingCharacters(in: .whitespaces),
                               foto: risposta.foto, giusta: numero == domanda.indiceGiusta)
            }
            return creata
        }
    }
}
