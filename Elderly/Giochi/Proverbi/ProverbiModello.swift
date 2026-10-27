import SwiftUI

/// "Completa il proverbio": si legge l'inizio e si sceglie la fine giusta. Stesse regole degli altri giochi:
/// nessuna sconfitta, si può riprovare, il punto va a chi aveva il turno.
@MainActor @Observable
final class ProverbiModello {
    struct Opzione: Identifiable, Hashable {
        let id = UUID()
        let testo: String
        let giusta: Bool
    }

    let giocatori: [Partecipante]
    private var proverbi: [Proverbio]
    private let quanti: Int
    private let numeroOpzioni: Int

    private(set) var indice = 0
    private(set) var punti: [Int]
    private(set) var opzioni: [Opzione] = []
    private(set) var sbagliate: Set<UUID> = []
    private(set) var trovata = false
    private var errori = 0
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        numeroOpzioni = difficolta.opzioniProverbi
        quanti = difficolta.turniProverbi
        proverbi = Array(Proverbio.tutti().shuffled().prefix(quanti))
        punti = Array(repeating: 0, count: giocatori.count)
        prepara()
    }

    var totale: Int { proverbi.count }
    var finito: Bool { indice >= proverbi.count }
    var turno: Int { indice % giocatori.count }
    var proverbio: Proverbio { proverbi[min(indice, proverbi.count - 1)] }
    var puntiTotali: Int { punti.reduce(0, +) }

    var testoParlato: String {
        let chi = giocatori.count > 1 && giocatori[turno].haNome ? "Tocca a \(giocatori[turno].nome). " : ""
        return chi + "Completa il proverbio. " + proverbio.inizio + ", e poi? " + opzioni.map(\.testo).joined(separator: ", oppure ")
    }

    func scegli(_ opzione: Opzione) {
        guard !trovata, !sbagliate.contains(opzione.id) else { return }
        if opzione.giusta {
            if errori == 0 { punti[turno] += 1 }
            trovata = true
            Sintetizzatore.condiviso.accordoDiFesta()
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaProverbio))
                guard !Task.isCancelled else { return }
                indice += 1
                prepara()
            }
        } else {
            // sbagliato: buzz, si vede il proverbio giusto e si va avanti da soli
            errori += 1
            sbagliate.insert(opzione.id)
            trovata = true
            Sintetizzatore.condiviso.buzz()
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaProverbio))
                guard !Task.isCancelled else { return }
                indice += 1
                prepara()
            }
        }
    }

    func ricomincia() {
        attesa?.cancel()
        proverbi = Array(Proverbio.tutti().shuffled().prefix(quanti))
        indice = 0
        punti = Array(repeating: 0, count: giocatori.count)
        prepara()
    }

    func ferma() { attesa?.cancel() }

    private func prepara() {
        guard !finito else { return }
        sbagliate = []; trovata = false; errori = 0
        let p = proverbi[indice]
        let sbagliateScelte = p.sbagliate.shuffled().prefix(numeroOpzioni - 1)
        opzioni = ([Opzione(testo: p.fine, giusta: true)] + sbagliateScelte.map { Opzione(testo: $0, giusta: false) }).shuffled()
    }
}
