import SwiftUI

struct ParoleImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Ricorda le parole",
            descrizione: "Guarda alcune foto e ricordale. Poi dimmi quali avevi già visto.",
            istruzioni: Istruzioni.parole,
            anteprima: { difficolta in
                VStack(spacing: 20) {
                    HStack(spacing: 14) {
                        ForEach(["foto_gatto", "foto_arancia", "foto_pizza"], id: \.self) { nome in
                            FotoView(foto: .risorsa(nome))
                                .aspectRatio(Configurazione.formaFoto, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    Text("\(difficolta.numeroParole) foto da ricordare")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .contentTransition(.numericText())
                }
                .animation(.spring(duration: 0.4), value: difficolta)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(difficolta.numeroParole) foto da ricordare")
            },
            partita: { difficolta in
                ParoleView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}

/// "Ricorda le parole": a sinistra la foto con il nome; a destra "Avanti" mentre si guarda,
/// poi la spunta verde (l'ho vista) e la X rossa (è nuova), come nel gioco "Sì o no".
struct ParoleView: View {
    @State private var modello: ParoleModello
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        _modello = State(initialValue: ParoleModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    gioco: .parole,
                    giocatori: modello.giocatori, punti: [],
                    sommario: "Risposte giuste: \(modello.punti) su \(modello.totale)",
                    totale: modello.totale, squadra: modello.punti,
                    ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito {
                BarraGiocatori(giocatori: modello.giocatori)
                Text(modello.contatore)
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
                    .fixedSize()
            }
        }
        .sensoryFeedback(.success, trigger: modello.punti) { prima, dopo in dopo > prima }
        .onChange(of: modello.messaggio) { _, nuovo in AccessibilityNotification.Announcement(nuovo).post() }
        .onDisappear { modello.ferma() }
    }

    @ViewBuilder private var partita: some View {
        if modello.fase == .guarda { guarda } else { ricorda }
    }

    /// Mentre si guarda: la foto grande quanto lo schermo permette, sotto il nome e "Avanti" a destra.
    private var guarda: some View {
        VStack(spacing: 12) {
            Text(modello.messaggio)
                .testo(DimensioneTesto.medio)
                .foregroundStyle(Tema.testoSecondario)
                .lineLimit(1).minimumScaleFactor(0.5)
            foto
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(spacing: 24) {
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 96)
                Text(modello.corrente.nome)
                    .testo(DimensioneTesto.enorme)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.4)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)
                Button { modello.avanti() } label: {
                    Label("Avanti", systemImage: "arrow.right")
                        .labelStyle(.titleAndIcon)
                        .testo(DimensioneTesto.grande)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40).frame(minHeight: 110)
                        .vetro(Tema.blu)
                        .fixedSize()
                }
                .buttonStyle(StilePremuto())
            }
        }
        .padding(.horizontal, 28).padding(.bottom, 20)
    }

    /// Mentre si risponde: la foto con il nome a sinistra, la spunta e la X grandi a destra.
    private var ricorda: some View {
        GeometryReader { spazio in
            let colonna = min(380, spazio.size.width * 0.32), distanza: CGFloat = 24
            HStack(alignment: .top, spacing: distanza) {
                VStack(spacing: 12) {
                    Text(modello.messaggio)
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testoSecondario)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .contentTransition(.opacity)
                    foto
                        .frame(maxHeight: .infinity)
                    Text(modello.corrente.nome)
                        .testo(DimensioneTesto.grande)
                        .foregroundStyle(Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .accessibilityAddTraits(.isHeader)
                    BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 20) {
                    pulsante(vista: true)
                    pulsante(vista: false)
                }
                .frame(width: colonna, height: spazio.size.height)
            }
        }
        .padding(.horizontal, 28).padding(.bottom, 20)
    }

    /// La foto in 16:9, il più grande possibile nello spazio che ha.
    private var foto: some View {
        FotoView(foto: modello.corrente.foto)
            .aspectRatio(Configurazione.formaFoto, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)
            .id(modello.corrente.id)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: modello.corrente.id)
            .accessibilityHidden(true)
    }

    /// Spunta verde = l'ho vista, X rossa = è nuova. Dopo la risposta resta in evidenza quella giusta.
    private func pulsante(vista: Bool) -> some View {
        let giusto = modello.corrente.vista == vista
        return Button { modello.rispondi(vista: vista) } label: {
            VStack(spacing: 8) {
                Image(systemName: vista ? "checkmark" : "xmark")
                    .font(.system(size: 120, weight: .heavy))
                Text(vista ? "L'ho vista" : "È nuova")
                    .testo(DimensioneTesto.medio)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(vista ? Tema.verde : Tema.rosso, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous)
                .stroke(Tema.testo, lineWidth: modello.inAttesa && giusto ? 10 : 0))
            .opacity(modello.inAttesa && !giusto ? 0.3 : 1)
            .scaleEffect(modello.inAttesa && giusto ? 1.03 : 1)
            .animation(.spring(duration: 0.4, bounce: 0.3), value: modello.inAttesa)
        }
        .buttonStyle(StilePremuto())
        .disabled(modello.inAttesa)
        .accessibilityLabel(vista ? "Sì, l'ho vista" : "No, è nuova")
    }
}
