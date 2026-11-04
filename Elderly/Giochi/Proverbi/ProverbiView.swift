import SwiftUI

/// "Completa il proverbio": a sinistra l'inizio, grande; a destra le possibili fini, ognuna un pulsante enorme.
struct ProverbiView: View {
    @State private var modello: ProverbiModello
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        _modello = State(initialValue: ProverbiModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    gioco: .proverbi,
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme: \(modello.puntiTotali) proverbi giusti su \(modello.totale)"
                        : "Proverbi giusti al primo colpo: \(modello.puntiTotali) su \(modello.totale)",
                    totale: modello.totale, ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito {
                BarraGiocatori(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)
                Text("\(modello.indice + 1) di \(modello.totale)")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
                    .fixedSize()
            }
        }
        .coloreSfondoDelTurno(modello.giocatori, turno: modello.turno)
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .sensoryFeedback(.success, trigger: modello.trovata) { _, nuova in nuova && modello.sbagliate.isEmpty }
        .sensoryFeedback(.warning, trigger: modello.sbagliate.count) { prima, dopo in dopo > prima }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            // l'inizio del proverbio, e dopo la risposta giusta il proverbio intero. Il testo vecchio sparisce
            // prima che arrivi il nuovo: se si sovrappongono, per un attimo le due frasi si leggono una sull'altra.
            ZStack {
                Text(modello.trovata ? modello.proverbio.completo : modello.proverbio.inizio + "\u{00A0}…")   // spazio che non va a capo: i puntini restano attaccati all'ultima parola
                    .testo(DimensioneTesto.enorme)
                    .foregroundStyle(Tema.testo)
                    .multilineTextAlignment(.center)
                    .lineLimit(3).minimumScaleFactor(0.4)
                    .id("\(modello.indice)-\(modello.trovata)")
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.3).delay(0.2)),
                                            removal: .opacity.animation(.easeOut(duration: 0.15))))
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 220)
            .padding(.horizontal, 32).padding(.vertical, 16)
            .scheda()
            .coloreDelTurno()

            // con tre o quattro fini, due per riga: le schede restano alte e si toccano bene anche sull'iPad mini
            let perRiga = modello.opzioni.count > 2 ? 2 : 1
            Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                ForEach(Array(stride(from: 0, to: modello.opzioni.count, by: perRiga)), id: \.self) { inizio in
                    GridRow {
                        ForEach(modello.opzioni[inizio..<min(inizio + perRiga, modello.opzioni.count)]) { opzione in
                            Button { modello.scegli(opzione) } label: { SchedaOpzione(opzione: opzione, stato: stato(opzione)) }
                                .buttonStyle(StilePremuto())
                                .accessibilityLabel(opzione.testo)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)

            HStack {
                Spacer()
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
            }
        }
        .padding(.horizontal, 32).padding(.bottom, 20)
    }

    private func stato(_ opzione: ProverbiModello.Opzione) -> SchedaOpzione.Stato {
        if modello.trovata && opzione.giusta { return .giusta }
        if modello.sbagliate.contains(opzione.id) { return .sbagliata }
        return .normale
    }
}

/// Una possibile fine del proverbio. La giusta diventa verde con la spunta, la sbagliata si spegne.
private struct SchedaOpzione: View {
    enum Stato { case normale, giusta, sbagliata }
    let opzione: ProverbiModello.Opzione
    let stato: Stato

    var body: some View {
        Text(opzione.testo)
            .testo(DimensioneTesto.grande)
            .foregroundStyle(stato == .normale ? Tema.testo : .white)
            .multilineTextAlignment(.center)
            .lineLimit(2).minimumScaleFactor(0.5)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(stato == .giusta ? Tema.verde : (stato == .sbagliata ? Tema.rosso : Tema.carta), in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .coloreDelTurno(attivo: stato == .normale)
            .shadow(color: Tema.testo.opacity(0.12), radius: 10, y: 5)
            .overlay(alignment: .trailing) {
                if stato != .normale {
                    Image(systemName: stato == .giusta ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 56)).foregroundStyle(.white).padding(.trailing, 28)
                }
            }
            .scaleEffect(stato == .giusta ? 1.02 : 1)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: stato)
    }
}
