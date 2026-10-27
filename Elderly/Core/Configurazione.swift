import Foundation

/// Tutti i numeri che si possono voler cambiare stanno qui, non sparsi nel codice.
enum Configurazione {
    /// Quante persone possono giocare insieme sullo stesso tablet.
    static let maxGiocatori = 2

    /// Quante domande ha una partita al quiz (le altre restano per la prossima volta).
    static let domandePerPartita = 6

    /// Quante risposte (foto) può avere una domanda, quando si crea un quiz.
    static let risposteMinime = 2
    static let risposteMassime = 3

    /// Secondi di pausa dopo una risposta giusta, prima della domanda successiva.
    static let pausaDopoRispostaGiusta = 2.5

    /// Lato massimo (in pixel) delle foto salvate: abbastanza per lo schermo, leggero per il database.
    static let latoFotoSalvata: CGFloat = 900
    static let latoFotoProfilo: CGFloat = 400
}
