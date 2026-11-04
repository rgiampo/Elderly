import Foundation

/// I tre livelli, uguali per tutti i giochi. Quanto è difficile lo decidono i numeri in `Configurazione`.
enum Difficolta: CaseIterable, Identifiable {
    case facile, medio, difficile   // "Suona le forme" usa solo facile e medio

    var id: Self { self }

    var nome: String {
        switch self {
        case .facile: "Facile"
        case .medio: "Medio"
        case .difficile: "Difficile"
        }
    }

    /// Quante forme ci sono nel gioco delle forme (il gioco offre solo facile e medio).
    var numeroForme: Int { self == .facile ? Configurazione.formeFacile : Configurazione.formeMedio }

    /// Con quante note comincia la sequenza nel gioco delle forme.
    var inizioForme: Int { self == .facile ? Configurazione.inizioFormeFacile : Configurazione.inizioFormeMedio }

    /// Quante coppie di carte ci sono nel gioco delle coppie.
    var numeroCoppie: Int {
        switch self {
        case .facile: Configurazione.coppieFacile
        case .medio: Configurazione.coppieMedio
        case .difficile: Configurazione.coppieDifficile
        }
    }

    /// Quanti proverbi ha una partita.
    var turniProverbi: Int {
        switch self {
        case .facile: Configurazione.turniProverbiFacile
        case .medio: Configurazione.turniProverbiMedio
        case .difficile: Configurazione.turniProverbiDifficile
        }
    }

    /// Tra quante fini scegliere (la giusta più le sbagliate).
    var opzioniProverbi: Int {
        switch self {
        case .facile: Configurazione.opzioniProverbiFacile
        case .medio: Configurazione.opzioniProverbiMedio
        case .difficile: Configurazione.opzioniProverbiDifficile
        }
    }

    /// Quante foto si guardano nel gioco "Cosa manca?".
    var fotoCosaManca: Int {
        switch self {
        case .facile: Configurazione.fotoCosaMancaFacile
        case .medio: Configurazione.fotoCosaMancaMedio
        case .difficile: Configurazione.fotoCosaMancaDifficile
        }
    }

    /// In quanti pezzi si divide la foto del puzzle.
    var grigliaPuzzle: (colonne: Int, righe: Int) {
        switch self {
        case .facile: Configurazione.puzzleFacile
        case .medio: Configurazione.puzzleMedio
        case .difficile: Configurazione.puzzleDifficile
        }
    }

    /// Quante foto si guardano in "Ricorda le parole".
    var numeroParole: Int {
        switch self {
        case .facile: Configurazione.paroleFacile
        case .medio: Configurazione.paroleMedio
        case .difficile: Configurazione.paroleDifficile
        }
    }

    /// Tra quante figure scegliere in "Ricorda le figure" (la vista più le simili).
    var scelteFigure: Int {
        switch self {
        case .facile: Configurazione.scelteFigureFacile
        case .medio: Configurazione.scelteFigureMedio
        case .difficile: Configurazione.scelteFigureDifficile
        }
    }

    var forme: [Forma] { Array(Forma.allCases.prefix(numeroForme)) }
}
