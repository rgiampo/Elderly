import Foundation

/// Un proverbio spezzato in due: l'inizio si legge, la fine va scelta tra più possibilità.
struct Proverbio: Decodable, Identifiable {
    let inizio: String
    let fine: String
    let sbagliate: [String]

    var id: String { inizio }
    var completo: String { "\(inizio) \(fine)" }

    /// Legge `proverbi.json`. Per aggiungere un proverbio basta copiare un blocco di quel file.
    static func tutti() -> [Proverbio] {
        guard let url = Bundle.main.url(forResource: "proverbi", withExtension: "json"),
              let dati = try? Data(contentsOf: url),
              let lista = try? JSONDecoder().decode([Proverbio].self, from: dati) else {
            print("proverbi.json non leggibile")
            return []
        }
        return lista
    }
}
