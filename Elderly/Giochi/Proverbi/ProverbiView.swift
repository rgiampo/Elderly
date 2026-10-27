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
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme: \(modello.puntiTotali) proverbi giusti su \(modello.totale)"
                        : "Proverbi giusti al primo colpo: \(modello.puntiTotali) su \(modello.totale)",
                    ricomincia: modello.ricomincia, esci: { chiudi() })
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
        .bordoTurno(modello.giocatori, turno: modello.turno)
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .sensoryFeedback(.success, trigger: modello.trovata) { _, nuova in nuova }
        .sensoryFeedback(.warning, trigger: modello.sbagliate.count) { prima, dopo in dopo > prima }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 20) {
            BannerTurno(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)

            // l'inizio del proverbio, e dopo la risposta giusta il proverbio intero
            VStack(spacing: 8) {
                Text(modello.trovata ? modello.proverbio.completo : modello.proverbio.inizio + " …")
                    .testo(DimensioneTesto.titolo)
                    .foregroundStyle(Tema.testo)
                    .multilineTextAlignment(.center)
                    .lineLimit(3).minimumScaleFactor(0.5)
                    .contentTransition(.opacity)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, minHeight: 190)
            .padding(.horizontal, 32).padding(.vertical, 20)
            .scheda()
            .animation(.easeInOut(duration: 0.4), value: modello.trovata)

            VStack(spacing: 16) {
                ForEach(modello.opzioni) { opzione in
                    Button { modello.scegli(opzione) } label: { SchedaOpzione(opzione: opzione, stato: stato(opzione)) }
                        .buttonStyle(StilePremuto())
                        .accessibilityLabel(opzione.testo)
                }
            }
            .frame(maxHeight: .infinity)

            HStack {
                Spacer()
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
            }
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
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
            .foregroundStyle(stato == .giusta ? .white : Tema.testo)
            .multilineTextAlignment(.center)
            .lineLimit(2).minimumScaleFactor(0.5)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(stato == .giusta ? Tema.verde : Tema.carta, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .shadow(color: Tema.testo.opacity(0.12), radius: 10, y: 5)
            .overlay(alignment: .trailing) {
                if stato == .giusta {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 56)).foregroundStyle(.white).padding(.trailing, 28)
                }
            }
            .opacity(stato == .sbagliata ? 0.35 : 1)
            .scaleEffect(stato == .giusta ? 1.02 : 1)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: stato)
    }
}
