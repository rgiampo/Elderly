import SwiftData
import Foundation

/// Serve a parlare alla persona al maschile o al femminile ("Bravissimo", "Bravissima").
enum Genere: String, CaseIterable, Identifiable {
    case maschio, femmina
    var id: String { rawValue }
    var nome: String { self == .maschio ? "Uomo" : "Donna" }
}

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
    /// Salvato come testo (opzionale): le persone create prima di questa scelta restano valide.
    var genereSalvato: String?
    @Attribute(.externalStorage) var foto: Data?

    var genere: Genere? {
        get { genereSalvato.flatMap(Genere.init(rawValue:)) }
        set { genereSalvato = newValue?.rawValue }
    }

    init(nome: String, cognome: String, eta: Int, dataDiNascita: Date? = nil, genere: Genere? = nil, foto: Data? = nil) {
        self.genereSalvato = genere?.rawValue
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
