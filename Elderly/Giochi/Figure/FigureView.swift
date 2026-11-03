import SwiftUI

/// "Ricorda le figure": prima una figura grande da guardare, poi le schede tra cui riconoscerla.
struct FigureView: View {
    @State private var modello: FigureModello
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        _modello = State(initialValue: FigureModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    gioco: .figure,
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme: \(modello.puntiTotali) figure riconosciute su \(modello.totale)"
                        : "Figure riconosciute al primo colpo: \(modello.puntiTotali) su \(modello.totale)",
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
        .animation(.spring(duration: 0.5), value: modello.fase)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .sensoryFeedback(.success, trigger: modello.fase) { _, nuova in nuova == .trovata && modello.sbagliata == nil }
        .sensoryFeedback(.warning, trigger: modello.sbagliata) { _, nuova in nuova != nil }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 20) {
            Text(modello.fase == .guarda ? "Guarda bene la figura" : "Quale figura hai visto?")
                .testo(DimensioneTesto.titolo)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)

            if modello.fase == .guarda {
                modello.figura.disegno(spessore: 18)
                    .padding(40)
                    .aspectRatio(1, contentMode: .fit)
                    .scheda()
                    .frame(maxHeight: .infinity)
                    .accessibilityLabel(modello.figura.nome)
            } else {
                HStack(spacing: 24) {
                    ForEach(modello.scelte, id: \.self) { figura in
                        Button { modello.scegli(figura) } label: { scheda(figura) }
                            .buttonStyle(StilePremuto())
                            .accessibilityLabel(figura.nome)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            HStack(spacing: 24) {
                if modello.fase == .guarda {
                    Button { modello.hoGuardato() } label: {
                        PulsantePrincipale(titolo: "Ho guardato", colore: Tema.verde, altezza: 110)
                    }
                    .buttonStyle(StilePremuto())
                } else {
                    Spacer()
                }
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                    .fixedSize()
            }
            .frame(height: 110)
        }
        .padding(.horizontal, 32).padding(.bottom, 20)
    }

    /// Una scheda da toccare. Dopo la risposta la giusta diventa verde con la spunta, la sbagliata rossa con la X.
    private func scheda(_ figura: Figura) -> some View {
        let giusta = modello.fase == .trovata && figura == modello.figura
        let sbagliata = figura == modello.sbagliata
        let forma = RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous)
        // con due persone il bordo prende il colore di chi gioca, come le carte di "Trova le coppie"
        let bordo = modello.giocatori.count > 1 ? Tema.coloreGiocatore(modello.turno) : Tema.celeste
        return figura.disegno(spessore: 12, colore: giusta || sbagliata ? .white : Tema.testo)
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(forma.fill(giusta ? Tema.verde : (sbagliata ? Tema.rosso : Tema.carta))
                .shadow(color: Tema.testo.opacity(0.15), radius: 10, y: 5))
            .overlay(forma.strokeBorder(bordo, lineWidth: giusta || sbagliata ? 0 : 6))
            .overlay(alignment: .topTrailing) {
                if giusta || sbagliata {
                    Image(systemName: giusta ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 44)).foregroundStyle(.white).padding(8)
                }
            }
            .scaleEffect(giusta ? 1.03 : 1)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: modello.fase)
    }
}
