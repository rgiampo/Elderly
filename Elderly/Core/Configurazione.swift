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

    /// Velocità della voce che legge: 1 = normale, meno di 1 = più lenta (meglio per chi ascolta con calma).
    static let velocitaVoce: Float = 0.9

    /// Lato più lungo (in pixel) delle foto salvate: abbastanza per lo schermo, leggero per il database.
    static let latoFotoSalvata: CGFloat = 1600   // foto delle risposte (sullo schermo sono circa 450 punti, cioè 1350 pixel)
    static let latoFotoProfilo: CGFloat = 600    // foto delle persone (si vedono in cerchi piccoli)
}
