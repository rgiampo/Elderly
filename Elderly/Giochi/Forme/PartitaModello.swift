import SwiftUI

enum Fase { case guarda, tocca, festa }

/// Logica del gioco: si ripete insieme una sequenza di forme, a turno, senza penalità.
/// Se chi gioca non tocca niente per qualche secondo, una mano gli indica la forma giusta.
@MainActor @Observable
final class PartitaModello {
    let forme: [Forma]
    let giocatori: [Partecipante]

    private(set) var giocatoreCorrente = 0
    private(set) var fase = Fase.guarda
    private(set) var formaAccesa: Forma?
    private(set) var formaSuggerita: Forma?
    private(set) var messaggio = ""
    private(set) var record = 0

    private var sequenza: [Forma] = []
    private var posizione = 0
    private var lunghezza: Int
    private var compito: Task<Void, Never>?
    private var suggerimento: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        forme = difficolta.forme
        lunghezza = difficolta.inizioForme
    }

    func inizia() { nuovaSequenza() }
    func ferma() { compito?.cancel(); suggerimento?.cancel() }

    func tocca(_ forma: Forma) {
        guard fase == .tocca else { return }
        accendi(forma)
        if forma == sequenza[posizione] {
            posizione += 1
            if posizione == sequenza.count { successo() } else { aspettaSuggerimento() }
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
        formaSuggerita = nil
        messaggio = "Guarda bene…"
        esegui {
            try await Task.sleep(for: .seconds(1))
            for forma in await self.sequenza {
                await self.accendi(forma, durata: Configurazione.pausaTraForme * 0.7)
                await AccessibilityNotification.Announcement(forma.nome).post()
                try await Task.sleep(for: .seconds(Configurazione.pausaTraForme))
            }
            await self.iniziaTurno()
        }
    }

    private func iniziaTurno() {
        fase = .tocca
        messaggio = "Tocca a te!"
        aspettaSuggerimento()
    }

    /// Se per qualche secondo non si tocca niente, la mano indica la forma da toccare adesso.
    private func aspettaSuggerimento() {
        suggerimento?.cancel()
        formaSuggerita = nil
        suggerimento = Task {
            try? await Task.sleep(for: .seconds(Configurazione.attesaSuggerimento))
            guard !Task.isCancelled, fase == .tocca else { return }
            withAnimation(.spring(duration: 0.5)) { formaSuggerita = sequenza[posizione] }
            messaggio = "Tocca qui!"
        }
    }

    private func successo() {
        suggerimento?.cancel()
        formaSuggerita = nil
        fase = .festa
        record = max(record, sequenza.count)
        messaggio = Frasi.bravi([giocatori[giocatoreCorrente]])
        esegui {
            try await Task.sleep(for: .seconds(0.4))
            for forma in self.forme {
                await self.suona(forma, volume: 0.6)
                try await Task.sleep(for: .seconds(0.12))
            }
            try await Task.sleep(for: .seconds(1.8))
            await self.passaAlProssimo(lunghezzaNuova: await self.lunghezza + 1)
        }
    }

    /// Un errore non penalizza: si dice "Riproviamo" e tocca all'altra persona (o di nuovo a chi gioca da solo), con la stessa sequenza.
    private func errore() {
        suggerimento?.cancel()
        formaSuggerita = nil
        fase = .guarda
        messaggio = "Riproviamo insieme"
        esegui {
            try await Task.sleep(for: .seconds(1.5))
            await self.passaAlProssimo(lunghezzaNuova: await self.lunghezza, stessaSequenza: true)
        }
    }

    /// Cambia il turno (a ogni giro, giusto o sbagliato).
    private func passaAlProssimo(lunghezzaNuova: Int, stessaSequenza: Bool = false) {
        lunghezza = lunghezzaNuova
        giocatoreCorrente = (giocatoreCorrente + 1) % giocatori.count
        if stessaSequenza { mostra() } else { nuovaSequenza() }
    }

    // MARK: - Aiuti

    /// Le pause dentro `lavoro` sono `try await`: quando il compito viene annullato (si esce dal gioco)
    /// la prima pausa lancia l'errore e il resto non suona più. Con `try?` il ciclo andava avanti a suonare.
    private func esegui(_ lavoro: @escaping @Sendable () async throws -> Void) {
        compito?.cancel()
        compito = Task { try? await lavoro() }
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
