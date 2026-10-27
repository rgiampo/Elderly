import Foundation

/// Chi sta giocando in questa partita. Può essere una persona salvata o "senza nome".
struct Partecipante: Identifiable, Hashable {
    let id: UUID
    let nome: String
    let utente: Utente?
    var genere: Genere? { utente?.genere }

    init(utente: Utente) {
        id = utente.id
        nome = utente.nome
        self.utente = utente
    }

    /// Chi gioca senza essere stato aggiunto nella lista Utenti.
    static let senzaNome = Partecipante()
    private init() {
        id = UUID()
        nome = ""
        utente = nil
    }

    var haNome: Bool { utente != nil }
}
