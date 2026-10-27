import SwiftUI

/// "Sì o no": a sinistra una foto grandissima, a destra il nome e due pulsanti enormi:
/// spunta verde per sì, X rossa per no (si distinguono anche per il segno, non solo per il colore).
struct SiNoView: View {
    @State private var modello: SiNoModello
    @Environment(\.dismiss) private var chiudi

    init(quiz: Quiz, giocatori: [Partecipante]) {
        _modello = State(initialValue: SiNoModello(quiz: quiz, giocatori: giocatori))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme: \(modello.puntiTotali) risposte giuste su \(modello.totale)"
                        : "Risposte giuste: \(modello.puntiTotali) su \(modello.totale)",
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
        .coloreSfondoDelTurno(modello.giocatori, turno: modello.turno)
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .onChange(of: modello.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .onDisappear { modello.ferma() }
    }

    /// A sinistra la foto 16:9 e sotto il nome; a destra i due pulsanti uno sopra l'altro, alti quanto lo schermo.
    private var partita: some View {
        GeometryReader { spazio in
            let colonna: CGFloat = 380, distanza: CGFloat = 28
            let larghezza = min(spazio.size.width - colonna - distanza, spazio.size.height * 0.62 * Configurazione.formaFoto)

            HStack(alignment: .top, spacing: distanza) {
                VStack(spacing: 16) {
                    FotoView(foto: modello.quesito.foto)
                        .frame(width: larghezza, height: larghezza / Configurazione.formaFoto)
                        .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
                        .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)
                        .id(modello.quesito.id)
                        .transition(.opacity)
                        .accessibilityHidden(true)

                    Text("Nella foto c'è:")
                        .testo(DimensioneTesto.titolo)
                        .foregroundStyle(Tema.testoSecondario)
                    Text(modello.quesito.nome)
                        .testo(DimensioneTesto.enorme)
                        .foregroundStyle(Tema.testo)
                        .multilineTextAlignment(.center)
                        .lineLimit(2).minimumScaleFactor(0.5)
                        .accessibilityAddTraits(.isHeader)
                    Spacer(minLength: 0)
                    BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                }
                .frame(width: larghezza, height: spazio.size.height)

                VStack(spacing: 20) {
                    pulsante(sì: true)
                    pulsante(sì: false)
                }
                .frame(width: colonna, height: spazio.size.height)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    /// Un pulsante pieno di colore con dentro solo il segno bianco (spunta o X). Tutta la superficie risponde al tocco.
    private func pulsante(sì: Bool) -> some View {
        let colore = sì ? Tema.verde : Tema.rosso
        // dopo la risposta resta in evidenza il pulsante giusto (con il bordo scuro), l'altro si spegne
        let giusto = modello.quesito.èGiusto == sì
        return Button { modello.rispondi(sì: sì) } label: {
            // solo il segno e il colore: spunta verde per sì, X rossa per no
            Image(systemName: sì ? "checkmark" : "xmark")
                .font(.system(size: 190, weight: .heavy))
                .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            .background(colore, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous)
                .stroke(Tema.testo, lineWidth: modello.inAttesa && giusto ? 10 : 0))
            .opacity(modello.inAttesa && !giusto ? 0.3 : 1)
            .scaleEffect(modello.inAttesa && giusto ? 1.03 : 1)
            .animation(.spring(duration: 0.4, bounce: 0.3), value: modello.inAttesa)
        }
        .buttonStyle(StilePremuto())
        .disabled(modello.inAttesa)
        .accessibilityLabel(sì ? "Sì" : "No")
    }
}
