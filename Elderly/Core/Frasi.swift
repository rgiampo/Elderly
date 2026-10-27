import Foundation

/// Le frasi che cambiano con chi gioca: al maschile, al femminile, al singolare o al plurale.
/// Se non sappiamo chi è (o chi sono) si usa un'espressione che va bene per tutti.
enum Frasi {
    /// "Bravissimo!", "Bravissima!", "Bravissimi!", "Bravissime!" oppure "Complimenti!".
    static func bravi(_ giocatori: [Partecipante]) -> String {
        let generi = giocatori.map(\.genere)
        guard !generi.isEmpty, !generi.contains(nil) else { return "Complimenti!" }
        if generi.count == 1 { return generi[0] == .femmina ? "Bravissima!" : "Bravissimo!" }
        return generi.allSatisfy { $0 == .femmina } ? "Bravissime!" : "Bravissimi!"
    }
}
