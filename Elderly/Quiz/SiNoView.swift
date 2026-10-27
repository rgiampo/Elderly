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
        .bordoTurno(modello.giocatori, turno: modello.turno)
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .onChange(of: modello.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            BannerTurno(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)

            HStack(spacing: 28) {
                FotoView(foto: modello.quesito.foto)
                    .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
                    .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)
                    .grandezzaFoto()
                    .id(modello.quesito.id)
                    .transition(.opacity)
                    .accessibilityHidden(true)

                VStack(spacing: 18) {
                    Text("Nella foto c'è:")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testoSecondario)
                    Text(modello.quesito.nome)
                        .testo(DimensioneTesto.titolo)
                        .foregroundStyle(Tema.testo)
                        .multilineTextAlignment(.center)
                        .lineLimit(3).minimumScaleFactor(0.5)
                        .accessibilityAddTraits(.isHeader)

                    Spacer(minLength: 0)
                    HStack(spacing: 20) {
                        pulsante(sì: true)
                        pulsante(sì: false)
                    }
                    Text(modello.messaggio.isEmpty ? " " : modello.messaggio)
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .lineLimit(2).minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                }
                .frame(width: 520)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    /// Un pulsante pieno di colore: la forma bianca (cerchio o triangolo) e la parola. Tutta la superficie risponde al tocco.
    private func pulsante(sì: Bool) -> some View {
        let colore = sì ? Tema.verde : Tema.rosso
        let scelto = modello.rispostaData == sì
        return Button { modello.rispondi(sì: sì) } label: {
            VStack(spacing: 14) {
                ZStack {
                    (sì ? AnyShape(Circle()) : AnyShape(SagomaTriangolo())).fill(.white)
                    Image(systemName: sì ? "checkmark" : "xmark")
                        .font(.system(size: 60, weight: .black))
                        .foregroundStyle(colore)
                        .offset(y: sì ? 0 : 16)
                }
                .frame(width: 150, height: 150)
                Text(sì ? "SÌ" : "NO").testo(DimensioneTesto.titolo).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
            .background(colore, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous)
                .stroke(Tema.testo, lineWidth: scelto ? 8 : 0))
            .opacity(modello.inAttesa && !scelto ? 0.35 : 1)
        }
        .buttonStyle(StilePremuto())
        .disabled(modello.inAttesa)
        .accessibilityLabel(sì ? "Sì" : "No")
    }
}
