import UIKit

/// Da dove arriva la foto di una risposta.
enum FotoQuiz: Hashable {
    case risorsa(String)   // una foto dentro l'app (cartella Assets)
    case dati(Data)        // una foto scelta da chi ha creato il quiz
}

extension FotoQuiz {
    /// La foto come dati JPEG, per poterla copiare in un quiz tutto nostro.
    var comeDati: Data? {
        switch self {
        case .dati(let dati): dati
        case .risorsa(let nome): UIImage(named: nome)?.jpegData(compressionQuality: 0.85)
        }
    }
}

struct RispostaQuiz: Identifiable, Hashable {
    let id = UUID()
    let testo: String
    let foto: FotoQuiz?
    let giusta: Bool
}

struct DomandaQuiz: Identifiable, Hashable {
    let id = UUID()
    let testo: String
    let risposte: [RispostaQuiz]

    var rispostaGiusta: RispostaQuiz? { risposte.first(where: \.giusta) }
    var foto: Set<FotoQuiz> { Set(risposte.compactMap(\.foto)) }

    /// Riduce la domanda a due risposte: quella giusta e una sbagliata scelta a caso.
    /// Due foto sole stanno più grandi sullo schermo e sono più facili da guardare.
    func conDueRisposte() -> DomandaQuiz {
        guard let giusta = rispostaGiusta else { return self }
        let sbagliate = risposte.filter { !$0.giusta }.shuffled()
        let scelte = ([giusta] + sbagliate.prefix(Configurazione.risposteMassime - 1)).shuffled()
        return DomandaQuiz(testo: testo, risposte: scelte)
    }
}

/// Un quiz: titolo e domande. Lo stesso tipo vale per i quiz pronti (JSON) e per quelli creati (SwiftData).
struct Quiz: Identifiable, Hashable {
    let id: String
    let titolo: String
    let domande: [DomandaQuiz]
    let èCreatoDaUtente: Bool

    /// Le domande di una partita: a caso, ridotte a due risposte, e senza che due domande di fila
    /// mostrino la stessa foto.
    func domandeDellaPartita(massimo: Int = Configurazione.domandePerPartita) -> [DomandaQuiz] {
        // una sola domanda per ogni foto giusta in una partita: così non si ripete la stessa cosa
        var viste = Set<String>()
        var rimaste = domande.shuffled().map { $0.conDueRisposte() }.filter { d in
            let chiave = d.rispostaGiusta?.testo ?? d.testo
            return viste.insert(chiave).inserted
        }
        var ordine: [DomandaQuiz] = []
        while ordine.count < massimo, !rimaste.isEmpty {
            let precedente = ordine.last?.foto ?? []
            let posizione = rimaste.firstIndex { $0.foto.isDisjoint(with: precedente) } ?? 0
            ordine.append(rimaste.remove(at: posizione))
        }
        return ordine
    }

    /// Le prime foto, per l'anteprima nell'elenco.
    var fotoAnteprima: [FotoQuiz] {
        var viste = Set<FotoQuiz>()
        return Array(domande.flatMap(\.risposte).compactMap(\.foto).filter { viste.insert($0).inserted }.prefix(3))
    }
}

// MARK: - Quiz pronti (file JSON dentro l'app)

/// Forma del file `quiz_*.json`. Per aggiungere un quiz pronto basta copiare `quiz_cucina.json`.
private struct QuizDaFile: Decodable {
    struct Domanda: Decodable {
        struct Risposta: Decodable { let testo: String; let foto: String?; let giusta: Bool }
        let testo: String
        let risposte: [Risposta]
    }
    let titolo: String
    let domande: [Domanda]
}

enum CatalogoQuiz {
    /// Tutte le foto dentro l'app, senza ripetizioni (servono al gioco delle coppie).
    static func fotoDellApp() -> [FotoQuiz] {
        var viste = Set<FotoQuiz>()
        return pronti().flatMap(\.domande).flatMap(\.risposte).compactMap(\.foto).filter { viste.insert($0).inserted }
    }

    /// Legge tutti i file `quiz_*.json` presenti nell'app.
    static func pronti() -> [Quiz] {
        let file = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        return file
            .filter { $0.lastPathComponent.hasPrefix("quiz_") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .compactMap(leggi)
    }

    private static func leggi(_ url: URL) -> Quiz? {
        guard let dati = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(QuizDaFile.self, from: dati) else {
            print("Quiz non leggibile:", url.lastPathComponent)
            return nil
        }
        let domande = file.domande.map { domanda in
            DomandaQuiz(testo: domanda.testo, risposte: domanda.risposte.map {
                RispostaQuiz(testo: $0.testo, foto: $0.foto.map(FotoQuiz.risorsa), giusta: $0.giusta)
            })
        }
        return Quiz(id: url.lastPathComponent, titolo: file.titolo, domande: domande, èCreatoDaUtente: false)
    }
}

// MARK: - Quiz creati

extension QuizCreato {
    var comeQuiz: Quiz {
        let domandeOrdinate = domande.sorted { $0.posizione < $1.posizione }.map { domanda in
            DomandaQuiz(testo: domanda.testo, risposte: domanda.risposte.sorted { $0.posizione < $1.posizione }.map {
                RispostaQuiz(testo: $0.testo, foto: $0.foto.map(FotoQuiz.dati), giusta: $0.giusta)
            })
        }
        return Quiz(id: id.uuidString, titolo: titolo, domande: domandeOrdinate, èCreatoDaUtente: true)
    }
}
