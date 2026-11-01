import SwiftUI

/// Prima schermata del gioco: prende i giocatori della sessione, come fanno le impostazioni degli altri giochi.
struct AnimaliIngressoView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View { AnimaliView(giocatori: sessione.giocatori) }
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
                    giocatori: modello.giocatori, punti: [],
                    sommario: "Animali detti: \(modello.totale)",
                    ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro { if !modello.finito { BarraGiocatori(giocatori: modello.giocatori) } }
        .sensoryFeedback(.success, trigger: modello.totale) { prima, dopo in dopo > prima }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            Text(modello.messaggio)
                .testo(DimensioneTesto.titolo)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, minHeight: 90)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: modello.totale)
                .accessibilityAddTraits(.isHeader)

            GeometryReader { geometria in
                let altezza = (geometria.size.height - spazio * CGFloat(righe - 1)) / CGFloat(righe)
                LazyVGrid(columns: colonne, spacing: spazio) {
                    ForEach(modello.animali) { animale in
                        Button { modello.tocca(animale) } label: {
                            SchedaAnimale(animale: animale, nominato: modello.nominati.contains(animale.id))
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
        .padding(.horizontal, 40).padding(.bottom, 24)
    }
}

/// Un animale: disegno e nome. Quando è stato detto diventa verde con la spunta (non solo il colore).
private struct SchedaAnimale: View {
    let animale: Animale
    let nominato: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(animale.emoji).font(.system(size: 70))
            Text(animale.nome)
                .testo(DimensioneTesto.normale)
                .lineLimit(1).minimumScaleFactor(0.5)
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
