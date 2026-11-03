import SwiftUI

/// Prima schermata del gioco: spiega come si gioca, poi "Giochiamo!".
struct SimboliIngressoView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        IstruzioniGiocoView(
            titolo: "Simboli e numeri",
            descrizione: "Ricorda quale numero ha ogni forma.",
            passi: [
                "Guarda la chiave e ricorda i numeri delle forme",
                "Poi la chiave si nasconde",
                "Per ogni forma grande tocca il suo numero, a memoria",
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
                    gioco: .simboli,
                    giocatori: modello.giocatori, punti: [],
                    sommario: "Giusti al primo colpo: \(modello.punti) su \(modello.totale)",
                    totale: modello.totale, squadra: modello.punti, ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito && !modello.staMemorizzando {
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

    @ViewBuilder private var partita: some View {
        if modello.staMemorizzando { memorizza } else { gioco }
    }

    /// Prima di giocare: la chiave grande al centro, da guardare con calma.
    private var memorizza: some View {
        VStack(spacing: 32) {
            Text("Ricorda il numero di ogni forma")
                .testo(DimensioneTesto.titolo)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)
            chiave(lato: 130)
                .frame(maxHeight: .infinity)
            HStack(spacing: 24) {
                BottoneVoce(testo: Istruzioni.simboli, etichetta: "Ascolta", altezza: 96)
                Button { withAnimation(.spring(duration: 0.4)) { modello.hoMemorizzato() } } label: {
                    PulsantePrincipale(titolo: "Ho memorizzato, giochiamo!", colore: Tema.verde, altezza: 110)
                }
                .buttonStyle(StilePremuto())
            }
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    private var gioco: some View {
        VStack(spacing: 20) {
            // la chiave è nascosta: si rivede per qualche secondo solo se serve
            ZStack {
                if modello.chiaveVisibile {
                    chiave(lato: 48).transition(.opacity)   // forme più piccole: la chiave sta tutta nella fascia
                } else {
                    Button { withAnimation { modello.rivediChiave() } } label: {
                        Label("Non ricordi? Rivedi i numeri", systemImage: "eye")
                            .testo(DimensioneTesto.medio)
                            .foregroundStyle(Tema.testo)
                            .lineLimit(1).minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scheda()
                    }
                    .buttonStyle(StilePremuto())
                    .disabled(modello.trovata)
                    .transition(.opacity)
                }
            }
            .frame(height: 140)
            .animation(.easeInOut(duration: 0.3), value: modello.chiaveVisibile)

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

    /// La chiave: sotto ogni forma il suo numero.
    private func chiave(lato: CGFloat) -> some View {
        HStack(spacing: 16) {
            ForEach(Array(modello.chiave.enumerated()), id: \.element) { posizione, forma in
                VStack(spacing: 6) {
                    forma.sagoma.fill(forma.colore).aspectRatio(1, contentMode: .fit).frame(height: lato)
                    Text("\(posizione + 1)").testo(lato < 60 ? DimensioneTesto.medio : DimensioneTesto.grande).foregroundStyle(Tema.testo)
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
