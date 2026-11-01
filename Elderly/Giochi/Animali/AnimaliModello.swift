import SwiftUI

/// "Nomina gli animali": chi gioca dice gli animali a voce e chi accompagna tocca quelli che sente.
/// Nessun timer e nessun errore possibile: un tocco in più si toglie toccando di nuovo.
@MainActor @Observable
final class AnimaliModello {
    let giocatori: [Partecipante]
    let animali = Animale.tutti

    private(set) var nominati: Set<Animale.ID> = []
    private(set) var altri = 0            // animali detti che non sono nella griglia
    private(set) var finito = false

    init(giocatori: [Partecipante]) {
        self.giocatori = giocatori
    }

    var totale: Int { nominati.count + altri }

    var messaggio: String { totale == 0 ? "Dì un animale e toccalo" : "Animali detti: \(totale)" }

    var testoParlato: String {
        "Dite gli animali che conoscete, uno alla volta. Chi accompagna tocca l'animale che sente. "
            + "Se l'animale non c'è, si tocca il pulsante: un altro animale."
    }

    func tocca(_ animale: Animale) {
        if nominati.contains(animale.id) {
            nominati.remove(animale.id)
        } else {
            nominati.insert(animale.id)
            Sintetizzatore.condiviso.accordoDiFesta()
        }
    }

    func aggiungiAltro() {
        altri += 1
        Sintetizzatore.condiviso.accordoDiFesta()
    }

    func termina() { finito = true }

    func ricomincia() {
        nominati = []
        altri = 0
        finito = false
    }
}
