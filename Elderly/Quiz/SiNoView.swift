import SwiftUI

/// "Sì o no": a sinistra una foto grandissima, a destra il nome e due pulsanti enormi:
/// cerchio verde per sì, triangolo rosso per no (si distinguono anche per la forma, non solo per il colore).
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

    /// Foto e pulsanti hanno la stessa altezza: il bordo in alto e quello in basso sono sulla stessa linea.
    private var partita: some View {
        VStack(spacing: 16) {
            GeometryReader { spazio in
                let colonna: CGFloat = 520, distanza: CGFloat = 28
                let larghezzaMassima = spazio.size.width - colonna - distanza
                // la foto è 3:2: l'altezza comune è quella che ci sta in larghezza, o tutta quella libera
                let altezza = min(spazio.size.height - 100, larghezzaMassima / Configurazione.formaFoto)
                let larghezza = altezza * Configurazione.formaFoto

                HStack(alignment: .top, spacing: distanza) {
                    FotoView(foto: modello.quesito.foto, intera: true)
                        .frame(width: larghezza, height: altezza)
                        .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
                        .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)
                        .id(modello.quesito.id)
                        .transition(.opacity)
                        .accessibilityHidden(true)

                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Text("Nella foto c'è:")
                                .testo(DimensioneTesto.medio)
                                .foregroundStyle(Tema.testoSecondario)
                            Text(modello.quesito.nome)
                                .testo(DimensioneTesto.enorme)
                                .foregroundStyle(Tema.testo)
                                .multilineTextAlignment(.center)
                                .lineLimit(2).minimumScaleFactor(0.5)
                                .accessibilityAddTraits(.isHeader)
                        }
                        .frame(height: 190)

                        HStack(spacing: 20) {
                            pulsante(sì: true)
                            pulsante(sì: false)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(width: colonna, height: altezza)
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                        .frame(width: colonna)
                        .offset(y: 92)
                }
            }
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    /// Un pulsante pieno di colore con dentro solo la forma bianca (cerchio o triangolo). Tutta la superficie risponde al tocco.
    private func pulsante(sì: Bool) -> some View {
        let colore = sì ? Tema.verde : Tema.rosso
        // dopo la risposta resta in evidenza il pulsante giusto (con il bordo scuro), l'altro si spegne
        let giusto = modello.quesito.èGiusto == sì
        return Button { modello.rispondi(sì: sì) } label: {
            // solo la forma e il colore: cerchio verde per sì, triangolo rosso per no
            (sì ? AnyShape(Circle()) : AnyShape(SagomaTriangolo()))
                .fill(.white)
                .frame(width: 190, height: 190)
            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
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
