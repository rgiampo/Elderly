import SwiftData
import Foundation

/// Una persona che gioca. SwiftData la salva da solo sul dispositivo.
@Model
final class Utente {
    var id = UUID()
    var nome: String
    var cognome: String
    var eta: Int
    @Attribute(.externalStorage) var foto: Data?

    init(nome: String, cognome: String, eta: Int, foto: Data? = nil) {
        self.nome = nome
        self.cognome = cognome
        self.eta = eta
        self.foto = foto
    }

    var nomeCompleto: String { "\(nome) \(cognome)" }
    var iniziali: String { String(nome.prefix(1) + cognome.prefix(1)).uppercased() }
}
