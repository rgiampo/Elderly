import Foundation

struct Risposta: Identifiable {
    let id = UUID()
    let testo: String
    let emoji: String   // shortcut: emoji provvisorie, da sostituire con foto vere (vedi licenze) quando le avremo
    let giusta: Bool
}

struct DomandaQuiz {
    let testo: String
    let risposte: [Risposta]
}

/// Le domande stanno qui, in chiaro: per aggiungerne una basta copiare un blocco.
enum DomandeCucina {
    static let tutte: [DomandaQuiz] = [
        DomandaQuiz(testo: "Quale pasta si usa per lo spaghetto alle vongole?", risposte: [
            Risposta(testo: "Spaghetti", emoji: "🍝", giusta: true),
            Risposta(testo: "Maccheroni", emoji: "🥘", giusta: false),
        ]),
        DomandaQuiz(testo: "Cosa va sulla pizza Margherita?", risposte: [
            Risposta(testo: "Mozzarella e basilico", emoji: "🧀", giusta: true),
            Risposta(testo: "Ananas", emoji: "🍍", giusta: false),
        ]),
        DomandaQuiz(testo: "Quale cereale c'è dentro la pastiera napoletana?", risposte: [
            Risposta(testo: "Grano", emoji: "🌾", giusta: true),
            Risposta(testo: "Riso", emoji: "🍚", giusta: false),
        ]),
        DomandaQuiz(testo: "Come si chiama il dolce a conchiglia ripieno di ricotta?", risposte: [
            Risposta(testo: "Sfogliatella", emoji: "🥐", giusta: true),
            Risposta(testo: "Babà", emoji: "🍰", giusta: false),
        ]),
        DomandaQuiz(testo: "Quale dolce napoletano è bagnato nel rum?", risposte: [
            Risposta(testo: "Babà", emoji: "🍰", giusta: true),
            Risposta(testo: "Struffoli", emoji: "🍯", giusta: false),
        ]),
        DomandaQuiz(testo: "Quanto cuoce il ragù napoletano?", risposte: [
            Risposta(testo: "Molte ore", emoji: "🕰️", giusta: true),
            Risposta(testo: "5 minuti", emoji: "⚡️", giusta: false),
        ]),
    ]
}
