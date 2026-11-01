import Foundation

/// Un animale della griglia. Il disegno è un emoji, quindi non servono foto e licenze.
struct Animale: Identifiable, Hashable {
    let nome: String
    let emoji: String
    var id: String { nome }

    static let tutti: [Animale] = [
        ("Cane", "🐶"), ("Gatto", "🐱"), ("Cavallo", "🐴"), ("Mucca", "🐮"),
        ("Maiale", "🐷"), ("Pecora", "🐑"), ("Gallina", "🐔"), ("Anatra", "🦆"),
        ("Coniglio", "🐰"), ("Leone", "🦁"), ("Tigre", "🐯"), ("Elefante", "🐘"),
        ("Giraffa", "🦒"), ("Scimmia", "🐵"), ("Orso", "🐻"), ("Lupo", "🐺"),
        ("Volpe", "🦊"), ("Pesce", "🐟"), ("Delfino", "🐬"), ("Tartaruga", "🐢"),
        ("Serpente", "🐍"), ("Rana", "🐸"), ("Farfalla", "🦋"), ("Ape", "🐝"),
    ].map { Animale(nome: $0.0, emoji: $0.1) }
}
