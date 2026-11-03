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

    private var partita: some View {
        GeometryReader { spazio in
            let colonna: CGFloat = 380, distanza: CGFloat = 28
            let larghezza = min(spazio.size.width - colonna - distanza, spazio.size.height * 0.58 * Configurazione.formaFoto)

            HStack(alignment: .top, spacing: distanza) {
                VStack(spacing: 14) {
                    Text(modello.messaggio)
                        .testo(DimensioneTesto.titolo)
                        .foregroundStyle(Tema.testoSecondario)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .contentTransition(.opacity)
                    FotoView(foto: modello.corrente.foto)
                        .frame(width: larghezza, height: larghezza / Configurazione.formaFoto)
                        .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
                        .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)
                        .id(modello.corrente.id)
                        .transition(.opacity)
                        .accessibilityHidden(true)
                    Text(modello.corrente.nome)
                        .testo(DimensioneTesto.enorme)
                        .foregroundStyle(Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .accessibilityAddTraits(.isHeader)
                    Spacer(minLength: 0)
                    BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                }
                .frame(width: larghezza, height: spazio.size.height)
                .animation(.easeInOut(duration: 0.3), value: modello.corrente.id)

                VStack(spacing: 20) {
                    if modello.fase == .guarda {
                        Button { modello.avanti() } label: {
                            Label("Avanti", systemImage: "arrow.right")
                                .testo(DimensioneTesto.grande)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Tema.blu, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
                        }
                        .buttonStyle(StilePremuto())
                    } else {
                        pulsante(vista: true)
                        pulsante(vista: false)
                    }
                }
                .frame(width: colonna, height: spazio.size.height)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
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
