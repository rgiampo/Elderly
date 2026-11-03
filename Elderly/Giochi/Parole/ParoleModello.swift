import SwiftUI

/// "Ricorda le parole", dal test CERAD: prima si guardano alcune foto con il nome, poi si mostrano
/// quelle viste mescolate ad altrettante nuove, e per ognuna si dice se l'avevi già vista.
/// Nessun timer: le foto da ricordare si guardano finché si vuole.
@MainActor @Observable
final class ParoleModello {
    struct Parola: Identifiable, Hashable {
        let id = UUID()
        let nome: String
        let foto: FotoQuiz
        let vista: Bool           // era tra quelle da ricordare
    }

    enum Fase { case guarda, ricorda }

    let giocatori: [Partecipante]
    private let quante: Int
    private(set) var daRicordare: [Parola] = []
    private(set) var domande: [Parola] = []
    private(set) var fase = Fase.guarda
    private(set) var indice = 0
    private(set) var punti = 0
    private(set) var risposta: Bool?      // cosa si è risposto alla foto corrente, finché si aspetta
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        quante = difficolta.numeroParole
        prepara()
    }

    var totale: Int { domande.count }
    var finito: Bool { fase == .ricorda && indice >= domande.count }
    var inAttesa: Bool { risposta != nil }
    var corrente: Parola {
        let elenco = fase == .guarda ? daRicordare : domande
        return elenco[min(indice, elenco.count - 1)]
    }

    var contatore: String {
        fase == .guarda ? "\(indice + 1) di \(daRicordare.count)" : "\(min(indice + 1, totale)) di \(totale)"
    }

    var messaggio: String {
        switch (fase, risposta) {
        case (.guarda, _): "Ricorda questa foto"
        case (.ricorda, nil): "L'avevi già vista?"
        case (.ricorda, .some(let detto)): detto == corrente.vista ? "Giusto!" : (corrente.vista ? "Era tra quelle viste" : "Questa è nuova")
        }
    }

    var testoParlato: String {
        fase == .guarda ? "Ricorda questa foto: \(corrente.nome)." : "\(corrente.nome). L'avevi già vista?"
    }

    /// Fase "guarda": si passa alla foto seguente; dopo l'ultima comincia la fase "ricorda".
    func avanti() {
        guard fase == .guarda else { return }
        if indice + 1 < daRicordare.count {
            indice += 1
        } else {
            fase = .ricorda
            indice = 0
        }
    }

    func rispondi(vista: Bool) {
        guard fase == .ricorda, risposta == nil, !finito else { return }
        risposta = vista
        if vista == corrente.vista {
            punti += 1
            Sintetizzatore.condiviso.accordoDiFesta()
        } else {
            Sintetizzatore.condiviso.buzz()
        }
        attesa = Task {
            try? await Task.sleep(for: .seconds(Configurazione.pausaParole))
            guard !Task.isCancelled else { return }
            indice += 1
            risposta = nil
        }
    }

    func ferma() { attesa?.cancel() }

    func ricomincia() {
        attesa?.cancel()
        prepara()
    }

    private func prepara() {
        // servono il doppio delle foto: metà da ricordare, metà nuove
        let scelte = CatalogoQuiz.paroleDellApp().shuffled().prefix(quante * 2)
        daRicordare = scelte.prefix(quante).map { Parola(nome: $0.nome, foto: $0.foto, vista: true) }
        let nuove = scelte.dropFirst(quante).map { Parola(nome: $0.nome, foto: $0.foto, vista: false) }
        domande = (daRicordare.map { Parola(nome: $0.nome, foto: $0.foto, vista: true) } + nuove).shuffled()
        fase = .guarda
        indice = 0
        punti = 0
        risposta = nil
    }
}
