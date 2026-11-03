import SwiftData
import Foundation

/// Una partita finita di una persona. Si salva da sola alla fine di ogni gioco, solo per chi gioca con il nome.
@Model
final class Risultato {
    var data: Date
    var giocoSalvato: String
    var punti: Int
    /// Il massimo possibile (per esempio 6 domande); nil nei giochi senza un massimo, come gli animali.
    var totale: Int?
    var utente: Utente?

    init(gioco: Gioco, punti: Int, totale: Int?, utente: Utente) {
        data = .now
        giocoSalvato = gioco.rawValue
        self.punti = punti
        self.totale = totale
        self.utente = utente
    }

    var gioco: Gioco? { Gioco(rawValue: giocoSalvato) }

    /// "7 su 10", oppure solo "7" se il gioco non ha un massimo.
    var testo: String { totale.map { "\(punti) su \($0)" } ?? "\(punti)" }

    /// Cosa conta il numero, gioco per gioco: senza questo "7" non vuol dire niente.
    var cosaConta: String {
        switch gioco {
        case .forme: "Sequenza più lunga"
        case .coppie: "Coppie trovate"
        case .cosaManca: "Foto riconosciute al primo colpo"
        case .proverbi: "Proverbi giusti al primo colpo"
        case .puzzle: "Puzzle completati"
        case .animali: "Animali detti"
        case .simboli: "Giusti al primo colpo"
        case .parole: "Foto riconosciute"
        case .quiz: "Risposte giuste al primo colpo"
        case .sìNo: "Risposte giuste"
        case nil: "Punti"
        }
    }

    /// Un risultato per ogni persona con il nome. Con `squadra` tutti prendono lo stesso punteggio
    /// (giochi fatti insieme, senza turni); altrimenti ognuno i suoi `punti`.
    static func salva(gioco: Gioco, giocatori: [Partecipante], punti: [Int], squadra: Int? = nil,
                      totale: Int? = nil, in contesto: ModelContext) {
        for (posizione, giocatore) in giocatori.enumerated() {
            guard let utente = giocatore.utente else { continue }
            let suoi = squadra ?? (posizione < punti.count ? punti[posizione] : 0)
            contesto.insert(Risultato(gioco: gioco, punti: suoi, totale: totale, utente: utente))
        }
    }
}
