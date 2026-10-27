import SwiftData
import Foundation

/// Una persona che gioca. SwiftData la salva da solo sul dispositivo.
@Model
final class Utente {
    var id = UUID()
    var nome: String
    var cognome: String
    /// Se c'è la data di nascita, l'età si calcola da sola e resta sempre aggiornata.
    var dataDiNascita: Date?
    /// Età scritta a mano: serve solo se non conosciamo la data di nascita.
    var eta: Int
    @Attribute(.externalStorage) var foto: Data?

    init(nome: String, cognome: String, eta: Int, dataDiNascita: Date? = nil, foto: Data? = nil) {
        self.nome = nome
        self.cognome = cognome
        self.eta = eta
        self.dataDiNascita = dataDiNascita
        self.foto = foto
    }

    var nomeCompleto: String { "\(nome) \(cognome)" }
    var iniziali: String { String(nome.prefix(1) + cognome.prefix(1)).uppercased() }

    /// L'età di oggi: dalla data di nascita se c'è, altrimenti quella scritta a mano.
    var etaAttuale: Int {
        Self.età(da: dataDiNascita) ?? eta
    }

    /// Quanti anni sono passati dalla data di nascita a oggi (`nil` se non c'è la data).
    static func età(da dataDiNascita: Date?, oggi: Date = .now) -> Int? {
        guard let dataDiNascita else { return nil }
        return Calendar.current.dateComponents([.year], from: dataDiNascita, to: oggi).year
    }
}
