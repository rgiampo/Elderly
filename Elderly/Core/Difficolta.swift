import Foundation

/// I tre livelli, uguali per tutti i giochi. Quanto è difficile lo decidono i numeri in `Configurazione`.
enum Difficolta: CaseIterable, Identifiable {
    case facile, medio, difficile, maestro   // il maestro esiste solo nel gioco delle forme

    var id: Self { self }

    var nome: String {
        switch self {
        case .facile: "Facile"
        case .medio: "Medio"
        case .difficile: "Difficile"
        case .maestro: "Maestro"
        }
    }

    /// Quante forme ci sono nel gioco delle forme.
    var numeroForme: Int {
        switch self {
        case .facile: Configurazione.formeFacile
        case .medio: Configurazione.formeMedio
        case .difficile: Configurazione.formeDifficile
        case .maestro: Configurazione.formeMaestro
        }
    }

    /// Di quante note cresce la sequenza a ogni giro.
    var passoForme: Int {
        switch self {
        case .facile: Configurazione.passoFacile
        case .medio: Configurazione.passoMedio
        case .difficile: Configurazione.passoDifficile
        case .maestro: Configurazione.passoMaestro
        }
    }

    /// Quante coppie di carte ci sono nel gioco delle coppie.
    var numeroCoppie: Int {
        switch self {
        case .facile: Configurazione.coppieFacile
        case .medio: Configurazione.coppieMedio
        case .difficile, .maestro: Configurazione.coppieDifficile
        }
    }

    /// Quanti proverbi ha una partita.
    var turniProverbi: Int {
        switch self {
        case .facile: Configurazione.turniProverbiFacile
        case .medio: Configurazione.turniProverbiMedio
        case .difficile, .maestro: Configurazione.turniProverbiDifficile
        }
    }

    /// Tra quante fini scegliere (la giusta più le sbagliate).
    var opzioniProverbi: Int {
        switch self {
        case .facile: Configurazione.opzioniProverbiFacile
        case .medio: Configurazione.opzioniProverbiMedio
        case .difficile, .maestro: Configurazione.opzioniProverbiDifficile
        }
    }

    /// Quante foto si guardano nel gioco "Cosa manca?".
    var fotoCosaManca: Int {
        switch self {
        case .facile: Configurazione.fotoCosaMancaFacile
        case .medio: Configurazione.fotoCosaMancaMedio
        case .difficile, .maestro: Configurazione.fotoCosaMancaDifficile
        }
    }

    /// In quanti pezzi si divide la foto del puzzle.
    var grigliaPuzzle: (colonne: Int, righe: Int) {
        switch self {
        case .facile: Configurazione.puzzleFacile
        case .medio: Configurazione.puzzleMedio
        case .difficile, .maestro: Configurazione.puzzleDifficile
        }
    }

    /// Quante foto si guardano in "Ricorda le parole".
    var numeroParole: Int {
        switch self {
        case .facile: Configurazione.paroleFacile
        case .medio: Configurazione.paroleMedio
        case .difficile, .maestro: Configurazione.paroleDifficile
        }
    }

    var forme: [Forma] { Array(Forma.allCases.prefix(numeroForme)) }
}
