import SwiftUI

/// Prima schermata del gioco: spiega come si gioca, poi "Giochiamo!".
struct SimboliIngressoView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        IstruzioniGiocoView(
            titolo: "Simboli e numeri",
            descrizione: "Ogni forma ha il suo numero. Trova quello giusto.",
            passi: [
                "In alto c'è la chiave: ogni forma ha un numero",
                "Guarda la forma grande al centro",
                "Tocca il suo numero",
            ],
            voce: Istruzioni.simboli,
            partita: { SimboliView(giocatori: sessione.giocatori) })
    }
}

/// "Simboli e numeri": la chiave in alto, la forma da riconoscere al centro, i numeri da toccare in basso.
struct SimboliView: View {
    @State private var modello: SimboliModello
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante]) {
        _modello = State(initialValue: SimboliModello(giocatori: giocatori))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    giocatori: modello.giocatori, punti: [],
                    sommario: "Giusti al primo colpo: \(modello.punti) su \(modello.totale)",
                    ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito {
                BarraGiocatori(giocatori: modello.giocatori)
                Text("\(modello.indice + 1) di \(modello.totale)")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
                    .fixedSize()
            }
        }
        .sensoryFeedback(.success, trigger: modello.trovata) { _, nuova in nuova && modello.sbagliati.isEmpty }
        .sensoryFeedback(.warning, trigger: modello.sbagliati.count) { prima, dopo in dopo > prima }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 20) {
            chiave

            // la forma da riconoscere, grande
            modello.corrente.sagoma
                .fill(modello.corrente.colore)
                .aspectRatio(1, contentMode: .fit)
                .padding(36)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scheda()
                .id(modello.indice)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(duration: 0.4), value: modello.indice)
                .accessibilityLabel(modello.corrente.nome)

            HStack(spacing: 16) {
                ForEach(modello.numeri, id: \.self) { numero in
                    Button { modello.scegli(numero) } label: {
                        SchedaNumero(numero: numero, stato: stato(numero))
                    }
                    .buttonStyle(StilePremuto())
                    .accessibilityLabel("\(numero)")
                }
            }
            .frame(height: 150)
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    /// La chiave: sopra ogni forma il suo numero, sempre visibile.
    private var chiave: some View {
        HStack(spacing: 16) {
            ForEach(Array(modello.chiave.enumerated()), id: \.element) { posizione, forma in
                VStack(spacing: 6) {
                    forma.sagoma.fill(forma.colore).aspectRatio(1, contentMode: .fit).frame(height: 70)
                    Text("\(posizione + 1)").testo(DimensioneTesto.grande).foregroundStyle(Tema.testo)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(forma.nome): numero \(posizione + 1)")
            }
        }
        .padding(.vertical, 12).padding(.horizontal, 24)
        .scheda()
    }

    private func stato(_ numero: Int) -> SchedaNumero.Stato {
        if modello.trovata && numero == modello.numeroGiusto { return .giusto }
        if modello.sbagliati.contains(numero) { return .sbagliato }
        return .normale
    }
}

/// Un numero da toccare. Il giusto diventa verde con la spunta, lo sbagliato si spegne con la X (non solo il colore).
private struct SchedaNumero: View {
    enum Stato { case normale, giusto, sbagliato }
    let numero: Int
    let stato: Stato

    var body: some View {
        Text("\(numero)")
            .testo(DimensioneTesto.enorme)
            .foregroundStyle(stato == .normale ? Tema.testo : .white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(stato == .giusto ? Tema.verde : (stato == .sbagliato ? Tema.rosso : Tema.carta), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Tema.testo.opacity(0.12), radius: 8, y: 4)
            .overlay(alignment: .topTrailing) {
                if stato != .normale {
                    Image(systemName: stato == .giusto ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 36)).foregroundStyle(.white).padding(10)
                }
            }
            .animation(.spring(duration: 0.3, bounce: 0.3), value: stato)
    }
}
