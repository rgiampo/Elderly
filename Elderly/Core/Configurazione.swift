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

    /// Proverbi: quanti per partita e quante fini tra cui scegliere, per ogni difficoltà.
    static let turniProverbiFacile = 5, turniProverbiMedio = 7, turniProverbiDifficile = 10
    static let opzioniProverbiFacile = 2, opzioniProverbiMedio = 3, opzioniProverbiDifficile = 3
    static let pausaProverbio = 3.0   // secondi per leggere il proverbio completo

    /// "Cosa manca?": quante foto si guardano e quante partite per ogni difficoltà.
    static let fotoCosaMancaFacile = 3, fotoCosaMancaMedio = 4, fotoCosaMancaDifficile = 6
    static let turniCosaManca = 5

    /// Secondi in cui due carte diverse restano scoperte, prima di girarsi di nuovo.
    static let pausaCarteDiverse = 1.6

    /// Secondi di pausa dopo una risposta giusta, prima della domanda successiva.
    static let pausaDopoRispostaGiusta = 2.5

    /// Velocità della voce che legge: 1 = normale, meno di 1 = più lenta (meglio per chi ascolta con calma).
    static let velocitaVoce: Float = 0.88

    /// Forma (larghezza / altezza) delle schede con la foto nei quiz: tutte le foto dell'app sono ritagliate così.
    static let formaFoto: CGFloat = 16.0 / 9.0

    /// Lato più lungo (in pixel) delle foto salvate: abbastanza per lo schermo, leggero per il database.
    static let latoFotoSalvata: CGFloat = 1600   // foto delle risposte (sullo schermo sono circa 450 punti, cioè 1350 pixel)
    static let latoFotoProfilo: CGFloat = 600    // foto delle persone (si vedono in cerchi piccoli)
}
