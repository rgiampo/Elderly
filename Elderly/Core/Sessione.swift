import SwiftUI

/// Le persone scelte nella schermata "Chi gioca?". Tutti i giochi la leggono da qui.
@Observable
final class Sessione {
    private(set) var scelti: [Partecipante] = []

    /// Chi gioca davvero: se nessuno è stato scelto, c'è una persona senza nome.
    var giocatori: [Partecipante] { scelti.isEmpty ? [.senzaNome] : scelti }
    var sceltaPiena: Bool { scelti.count >= Configurazione.maxGiocatori }

    func èScelto(_ utente: Utente) -> Bool { scelti.contains { $0.id == utente.id } }

    /// Tocca una persona: la sceglie, oppure la toglie se era già scelta.
    func alterna(_ utente: Utente) {
        if let posizione = scelti.firstIndex(where: { $0.id == utente.id }) {
            scelti.remove(at: posizione)
        } else if !sceltaPiena {
            scelti.append(Partecipante(utente: utente))
        }
    }
}
