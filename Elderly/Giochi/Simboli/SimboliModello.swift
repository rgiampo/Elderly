import SwiftUI

/// "Simboli e numeri": una chiave dice quale numero ha ogni forma, e si tocca il numero della forma grande.
/// Nessun timer: se si sbaglia si riprova, il punto vale solo se si indovina al primo colpo.
@MainActor @Observable
final class SimboliModello {
    static let simboli: [Forma] = [.cerchio, .quadrato, .triangolo, .stella, .cuore]

    let giocatori: [Partecipante]
    private(set) var chiave: [Forma]            // la posizione + 1 è il numero della forma
    private var sequenza: [Forma]
    private(set) var indice = 0
    private(set) var punti = 0
    private(set) var sbagliati: Set<Int> = []
    private(set) var trovata = false
    private var errori = 0
    private var attesa: Task<Void, Never>?

    init(giocatori: [Partecipante]) {
        self.giocatori = giocatori
        chiave = Self.simboli.shuffled()
        sequenza = Self.nuovaSequenza()
    }

    var numeri: [Int] { Array(1...chiave.count) }
    var totale: Int { sequenza.count }
    var finito: Bool { indice >= sequenza.count }
    var corrente: Forma { sequenza[min(indice, sequenza.count - 1)] }
    var numeroGiusto: Int { (chiave.firstIndex(of: corrente) ?? 0) + 1 }

    func scegli(_ numero: Int) {
        guard !trovata, !sbagliati.contains(numero) else { return }
        if numero == numeroGiusto {
            if errori == 0 { punti += 1 }
            trovata = true
            Sintetizzatore.condiviso.accordoDiFesta()
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaSimboli))
                guard !Task.isCancelled else { return }
                indice += 1
                sbagliati = []; trovata = false; errori = 0
            }
        } else {
            errori += 1
            sbagliati.insert(numero)
            Sintetizzatore.condiviso.buzz()
        }
    }

    func ferma() { attesa?.cancel() }

    func ricomincia() {
        attesa?.cancel()
        chiave = Self.simboli.shuffled()
        sequenza = Self.nuovaSequenza()
        indice = 0; punti = 0; sbagliati = []; trovata = false; errori = 0
    }

    private static func nuovaSequenza() -> [Forma] {
        (0..<Configurazione.turniSimboli).map { _ in simboli.randomElement()! }
    }
}
