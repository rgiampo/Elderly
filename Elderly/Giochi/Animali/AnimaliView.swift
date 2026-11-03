import SwiftUI

/// Prima schermata del gioco: spiega come si gioca, poi "Giochiamo!".
struct AnimaliIngressoView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        IstruzioniGiocoView(
            titolo: "Nomina gli animali",
            descrizione: "Quanti animali conosci? Uno dice, l'altro tocca.",
            passi: [
                "Chi gioca dice un animale a voce",
                "Chi accompagna lo tocca sullo schermo",
                "Si va avanti finché non ne vengono più in mente",
            ],
            voce: Istruzioni.animali,
            partita: { AnimaliView(giocatori: sessione.giocatori) })
    }
}

/// "Nomina gli animali": una griglia di animali grandi da toccare quando vengono nominati, senza tempo.
struct AnimaliView: View {
    @State private var modello: AnimaliModello
    @Environment(\.dismiss) private var chiudi

    private let colonne = Array(repeating: GridItem(.flexible(), spacing: 14), count: 6)
    private let righe = 4
    private let spazio: CGFloat = 14

    init(giocatori: [Partecipante]) {
        _modello = State(initialValue: AnimaliModello(giocatori: giocatori))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    gioco: .animali,
                    giocatori: modello.giocatori, punti: [],
                    sommario: "Animali detti: \(modello.totale)",
                    squadra: modello.totale, ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito {
                // il messaggio sta nella barra in alto: tutto lo schermo resta per la griglia degli animali
                Text(modello.messaggio)
                    .testo(DimensioneTesto.grande)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: modello.totale)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 12)
                BarraGiocatori(giocatori: modello.giocatori)
            }
        }
        .sensoryFeedback(.success, trigger: modello.totale) { prima, dopo in dopo > prima }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            GeometryReader { geometria in
                let altezza = (geometria.size.height - spazio * CGFloat(righe - 1)) / CGFloat(righe)
                LazyVGrid(columns: colonne, spacing: spazio) {
                    ForEach(modello.animali) { animale in
                        Button { modello.tocca(animale) } label: {
                            // sugli schermi piccoli (iPad mini) le schede sono basse: solo l'emoji, grande quanto la scheda
                            SchedaAnimale(animale: animale, nominato: modello.nominati.contains(animale.id),
                                          altezza: altezza, conNome: altezza >= 120)
                                .frame(height: altezza)
                        }
                        .buttonStyle(StilePremuto())
                        .accessibilityLabel(animale.nome)
                        .accessibilityAddTraits(modello.nominati.contains(animale.id) ? .isSelected : [])
                    }
                }
            }

            HStack(spacing: 24) {
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 96)
                Button { modello.aggiungiAltro() } label: { PulsanteSecondario(titolo: "Un altro animale", altezza: 96) }
                    .buttonStyle(StilePremuto())
                Button { modello.termina() } label: { PulsantePrincipale(titolo: "Ho finito", colore: Tema.verde, altezza: 96) }
                    .buttonStyle(StilePremuto())
                    .disabled(modello.totale == 0)
                    .opacity(modello.totale == 0 ? 0.5 : 1)
            }
        }
        .padding(.horizontal, 24).padding(.bottom, 20)
    }
}

/// Un animale: disegno e nome. Quando è stato detto diventa verde con la spunta (non solo il colore).
private struct SchedaAnimale: View {
    let animale: Animale
    let nominato: Bool
    var altezza: CGFloat = 150
    var conNome = true

    var body: some View {
        VStack(spacing: 4) {
            // l'emoji si ingrandisce fino a riempire lo spazio della scheda (in alto se c'è anche il nome)
            Text(animale.emoji)
                .font(.system(size: 200))
                .minimumScaleFactor(0.05)
                .lineLimit(1)
                .frame(maxHeight: conNome ? altezza * 0.5 : altezza * 0.9)
            if conNome {
                Text(animale.nome)
                    .testo(DimensioneTesto.normale)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1).minimumScaleFactor(0.5)
            }
        }
        .foregroundStyle(nominato ? .white : Tema.testo)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(nominato ? Tema.verde : Tema.carta, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Tema.testo.opacity(0.12), radius: 8, y: 4)
        .overlay(alignment: .topTrailing) {
            if nominato {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 36)).foregroundStyle(.white).padding(10)
            }
        }
        .animation(.spring(duration: 0.3, bounce: 0.3), value: nominato)
    }
}
