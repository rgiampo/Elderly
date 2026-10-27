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
    private let melodie: [Melodia]
    private var numeroMelodia = 0
    private(set) var titoloMelodia: String?        // se si sta suonando una melodia conosciuta
    private var posizione = 0
    private var lunghezza = 2
    private var compito: Task<Void, Never>?

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        self.giocatori = giocatori
        self.forme = difficolta.forme
        melodie = Melodia.perLivello(difficolta.numeroForme).shuffled()
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
        if let melodia = melodiaCorrente {
            // si riascolta l'inizio della melodia, un po' più lungo a ogni giro
            titoloMelodia = melodia.titolo
            sequenza = melodia.note.prefix(lunghezza).map { forme[$0] }
        } else {
            titoloMelodia = nil
            sequenza = (0..<lunghezza).map { _ in forme.randomElement()! }
        }
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
        record = max(record, sequenza.count)
        let finita = melodiaCorrente.map { sequenza.count >= $0.note.count } ?? false
        messaggio = finita ? "Hai suonato \(titoloMelodia ?? "la melodia")!" : Frasi.bravi([giocatori[giocatoreCorrente]])
        esegui {
            try? await Task.sleep(for: .seconds(0.4))
            if finita {
                // la melodia intera, senza pause, come una canzone
                for forma in await self.sequenza {
                    await self.accendi(forma, durata: 0.35)
                    try? await Task.sleep(for: .seconds(0.42))
                }
                try? await Task.sleep(for: .seconds(1.5))
            } else {
                for forma in await self.forme {
                    await self.suona(forma, volume: 0.6)
                    try? await Task.sleep(for: .seconds(0.12))
                }
                try? await Task.sleep(for: .seconds(1.8))
            }
            await self.passaAlProssimo(lunghezzaNuova: finita ? 2 : await self.lunghezza + 1, nuovaMelodia: finita)
        }
    }

    /// Un errore non penalizza: si dice "Riproviamo" e tocca all'altra persona (o di nuovo a chi gioca da solo), con la stessa sequenza.
    private func errore() {
        fase = .guarda
        messaggio = "Riproviamo insieme"
        esegui {
            try? await Task.sleep(for: .seconds(1.5))
            await self.passaAlProssimo(lunghezzaNuova: await self.lunghezza, nuovaMelodia: false, stessaSequenza: true)
        }
    }

    /// Cambia il turno (a ogni giro, giusto o sbagliato). Dopo una melodia finita si passa alla prossima.
    private func passaAlProssimo(lunghezzaNuova: Int, nuovaMelodia: Bool, stessaSequenza: Bool = false) {
        lunghezza = lunghezzaNuova
        giocatoreCorrente = (giocatoreCorrente + 1) % giocatori.count
        if nuovaMelodia, !melodie.isEmpty { numeroMelodia += 1 }
        if stessaSequenza { mostra() } else { nuovaSequenza() }
    }

    private var melodiaCorrente: Melodia? { melodie.isEmpty ? nil : melodie[numeroMelodia % melodie.count] }

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
