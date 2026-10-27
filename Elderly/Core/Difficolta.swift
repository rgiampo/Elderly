import Foundation

/// I tre livelli, uguali per tutti i giochi. Quanto è difficile lo decidono i numeri in `Configurazione`.
enum Difficolta: CaseIterable, Identifiable {
    case facile, medio, difficile

    var id: Self { self }

    var nome: String {
        switch self {
        case .facile: "Facile"
        case .medio: "Medio"
        case .difficile: "Difficile"
        }
    }

    /// Quante forme ci sono nel gioco delle forme.
    var numeroForme: Int {
        switch self {
        case .facile: Configurazione.formeFacile
        case .medio: Configurazione.formeMedio
        case .difficile: Configurazione.formeDifficile
        }
    }

    /// Quante coppie di carte ci sono nel gioco delle coppie.
    var numeroCoppie: Int {
        switch self {
        case .facile: Configurazione.coppieFacile
        case .medio: Configurazione.coppieMedio
        case .difficile: Configurazione.coppieDifficile
        }
    }

    var forme: [Forma] { Array(Forma.allCases.prefix(numeroForme)) }
}
