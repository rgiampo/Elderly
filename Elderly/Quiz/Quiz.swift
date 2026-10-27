import Foundation

/// Da dove arriva la foto di una risposta.
enum FotoQuiz: Hashable {
    case risorsa(String)   // una foto dentro l'app (cartella Assets)
    case dati(Data)        // una foto scelta da chi ha creato il quiz
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
}

/// Un quiz: titolo e domande. Lo stesso tipo vale per i quiz pronti (JSON) e per quelli creati (SwiftData).
struct Quiz: Identifiable, Hashable {
    let id: String
    let titolo: String
    let domande: [DomandaQuiz]
    let èCreatoDaUtente: Bool

    /// Le prime foto, per l'anteprima nell'elenco.
    var fotoAnteprima: [FotoQuiz] {
        Array(domande.flatMap(\.risposte).compactMap(\.foto).prefix(3))
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
