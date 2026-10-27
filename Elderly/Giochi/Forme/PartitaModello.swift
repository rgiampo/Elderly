import SwiftUI

enum Fase { case guarda, tocca, festa }

/// Logica del gioco: si ripete insieme una sequenza di forme, a turno, senza penalità.
@MainActor @Observable
final class PartitaModello {
    let forme: [Forma]
    let giocatori: [Partecipante]

    private(set) var giocatoreCorrente = 0
    private(set) var fase = Fase.guarda
    private(set) var formaAccesa: Forma?
    private(set) var messaggio = ""
    private(set) var record = 0

    private var sequenza: [Forma] = []
    private var posizione = 0
    private var lunghezza = 2
    private var erroriDiFila = 0
    private var compito: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        self.forme = difficolta.forme
    }

    func inizia() { nuovaSequenza() }
    func ferma() { compito?.cancel() }

    func tocca(_ forma: Forma) {
        guard fase == .tocca else { return }
        accendi(forma)
        if forma == sequenza[posizione] {
            posizione += 1
            if posizione == sequenza.count { successo() }
        } else {
            errore()
        }
    }

    // MARK: - Passi del gioco

    private func nuovaSequenza() {
        sequenza = (0..<lunghezza).map { _ in forme.randomElement()! }
        mostra()
    }

    private func mostra() {
        fase = .guarda
        posizione = 0
        messaggio = "Guarda bene…"
        esegui {
            try? await Task.sleep(for: .seconds(1))
            for forma in await self.sequenza {
                await self.accendi(forma, durata: 0.7)
                await AccessibilityNotification.Announcement(forma.nome).post()
                try? await Task.sleep(for: .seconds(1))
            }
            await self.iniziaTurno()
        }
    }

    private func iniziaTurno() {
        fase = .tocca
        messaggio = "Tocca a te!"
    }

    private func successo() {
        fase = .festa
        erroriDiFila = 0
        record = max(record, sequenza.count)
        messaggio = Frasi.bravi([giocatori[giocatoreCorrente]])
        esegui {
            try? await Task.sleep(for: .seconds(0.4))
            for forma in await self.forme {
                await self.suona(forma, volume: 0.6)
                try? await Task.sleep(for: .seconds(0.12))
            }
            try? await Task.sleep(for: .seconds(2))
            await self.passaAlProssimo(lunghezzaNuova: await self.lunghezza + 1)
        }
    }

    private func errore() {
        erroriDiFila += 1
        fase = .guarda
        messaggio = "Riproviamo insieme"
        esegui {
            try? await Task.sleep(for: .seconds(1.5))
            if await self.erroriDiFila >= 2 {
                await self.passaAlProssimo(lunghezzaNuova: max(2, await self.lunghezza - 1))
            } else {
                await self.mostra()
            }
        }
    }

    private func passaAlProssimo(lunghezzaNuova: Int) {
        lunghezza = lunghezzaNuova
        erroriDiFila = 0
        giocatoreCorrente = (giocatoreCorrente + 1) % giocatori.count
        nuovaSequenza()
    }

    // MARK: - Aiuti

    private func esegui(_ lavoro: @escaping @Sendable () async -> Void) {
        compito?.cancel()
        compito = Task { await lavoro() }
    }

    private func suona(_ forma: Forma, volume: Float = 0.8) {
        Sintetizzatore.condiviso.suona(forma.frequenza, volume: volume)
    }

    private func accendi(_ forma: Forma, durata: Double = 0.4) {
        suona(forma)
        withAnimation(.spring(duration: 0.25, bounce: 0.5)) { formaAccesa = forma }
        Task {
            try? await Task.sleep(for: .seconds(durata))
            withAnimation(.easeOut(duration: 0.25)) { formaAccesa = nil }
        }
    }
}
