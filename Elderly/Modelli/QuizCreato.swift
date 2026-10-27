import SwiftData
import Foundation

/// Quiz creati da chi accompagna il gioco. SwiftData li salva sul tablet, foto comprese.
@Model
final class QuizCreato {
    var id = UUID()
    var titolo: String
    var creatoIl = Date()
    @Relationship(deleteRule: .cascade) var domande: [DomandaCreata] = []

    init(titolo: String) { self.titolo = titolo }
}

@Model
final class DomandaCreata {
    var posizione: Int
    var testo: String
    @Relationship(deleteRule: .cascade) var risposte: [RispostaCreata] = []

    init(posizione: Int, testo: String) {
        self.posizione = posizione
        self.testo = testo
    }
}

@Model
final class RispostaCreata {
    var posizione: Int
    var testo: String
    @Attribute(.externalStorage) var foto: Data?
    var giusta: Bool

    init(posizione: Int, testo: String, foto: Data?, giusta: Bool) {
        self.posizione = posizione
        self.testo = testo
        self.foto = foto
        self.giusta = giusta
    }
}
