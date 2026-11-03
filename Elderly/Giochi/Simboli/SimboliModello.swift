import SwiftUI

/// "Simboli e numeri": all'inizio si guarda la chiave (quale numero ha ogni forma) e la si ricorda;
/// poi la chiave si nasconde e per ogni forma grande si tocca il suo numero, a memoria.
/// Nessun timer: la chiave si può rivedere quando si vuole, ma il punto vale solo se si indovina
/// al primo colpo e senza averla rivista.
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
    private(set) var staMemorizzando = true   // all'inizio: si guarda la chiave, non si gioca ancora
    private(set) var chiaveVisibile = true
    private var errori = 0
    private var rivista = false               // in questa domanda si è rivista la chiave
    private var nascondi: Task<Void, Never>?
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

    /// Finito di guardare la chiave: si nasconde e comincia il gioco.
    func hoMemorizzato() {
        staMemorizzando = false
        chiaveVisibile = false
    }

    /// Mostra la chiave per qualche secondo, poi la nasconde di nuovo.
    func rivediChiave() {
        guard !staMemorizzando else { return }
        rivista = true
        chiaveVisibile = true
        nascondi?.cancel()
        nascondi = Task {
            try? await Task.sleep(for: .seconds(Configurazione.chiaveSimboliVisibile))
            guard !Task.isCancelled else { return }
            chiaveVisibile = false
        }
    }

    func scegli(_ numero: Int) {
        guard !staMemorizzando, !trovata, !sbagliati.contains(numero) else { return }
        if numero == numeroGiusto {
            if errori == 0 && !rivista { punti += 1 }
            trovata = true
            Sintetizzatore.condiviso.accordoDiFesta()
            attesa = Task {
                try? await Task.sleep(for: .seconds(Configurazione.pausaSimboli))
                guard !Task.isCancelled else { return }
                indice += 1
                sbagliati = []; trovata = false; errori = 0; rivista = false
            }
        } else {
            errori += 1
            sbagliati.insert(numero)
            Sintetizzatore.condiviso.buzz()
        }
    }

    func ferma() { attesa?.cancel(); nascondi?.cancel() }

    func ricomincia() {
        attesa?.cancel()
        chiave = Self.simboli.shuffled()
        sequenza = Self.nuovaSequenza()
        indice = 0; punti = 0; sbagliati = []; trovata = false; errori = 0; rivista = false
        nascondi?.cancel()
        staMemorizzando = true
        chiaveVisibile = true
    }

    private static func nuovaSequenza() -> [Forma] {
        (0..<Configurazione.turniSimboli).map { _ in simboli.randomElement()! }
    }
}
