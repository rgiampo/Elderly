import Foundation

/// Tutti i numeri che si possono voler cambiare stanno qui, non sparsi nel codice.
enum Configurazione {
    /// Quante persone possono giocare insieme sullo stesso tablet.
    static let maxGiocatori = 2

    /// Quante domande ha una partita al quiz (le altre restano per la prossima volta).
    static let domandePerPartita = 6

    /// Quante risposte (foto) ha una domanda: due, così le foto stanno grandi sullo schermo.
    static let risposteMinime = 2
    static let risposteMassime = 2

    /// Quante forme ci sono nel gioco delle forme, per ogni difficoltà.
    static let formeFacile = 3, formeMedio = 4, formeDifficile = 5

    /// Quante coppie di foto ci sono nel gioco delle coppie, per ogni difficoltà.
    static let coppieFacile = 3, coppieMedio = 4, coppieDifficile = 6

    /// Secondi in cui due carte diverse restano scoperte, prima di girarsi di nuovo.
    static let pausaCarteDiverse = 1.6

    /// Secondi di pausa dopo una risposta giusta, prima della domanda successiva.
    static let pausaDopoRispostaGiusta = 2.5

    /// Velocità della voce che legge: 1 = normale, meno di 1 = più lenta (meglio per chi ascolta con calma).
    static let velocitaVoce: Float = 0.88

    /// Forma (larghezza / altezza) delle schede con la foto nei quiz: quella delle foto più comuni, così si vedono intere.
    static let formaFoto: CGFloat = 3.0 / 2.0

    /// Lato più lungo (in pixel) delle foto salvate: abbastanza per lo schermo, leggero per il database.
    static let latoFotoSalvata: CGFloat = 1600   // foto delle risposte (sullo schermo sono circa 450 punti, cioè 1350 pixel)
    static let latoFotoProfilo: CGFloat = 600    // foto delle persone (si vedono in cerchi piccoli)
}
