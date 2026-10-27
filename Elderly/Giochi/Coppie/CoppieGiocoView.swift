import SwiftUI

/// Il gioco delle coppie, tutto in una schermata: le carte riempiono lo spazio, così le foto sono grandi.
struct CoppieGiocoView: View {
    @State private var modello: CoppieModello
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        _modello = State(initialValue: CoppieModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme avete trovato \(modello.puntiTotali) coppie"
                        : "Hai trovato \(modello.puntiTotali) coppie",
                    ricomincia: modello.ricomincia, esci: { chiudi() })
            } else {
                partita
            }
        }
        .conIndietro {
            if !modello.finito { BarraGiocatori(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti) }
        }
        .bordoTurno(modello.giocatori, turno: modello.turno)
        .animation(.spring(duration: 0.5), value: modello.turno)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .sensoryFeedback(.success, trigger: modello.puntiTotali)
        .onChange(of: modello.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            BannerTurno(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)

            GeometryReader { spazio in
                let distanza: CGFloat = 20
                let larghezza = (spazio.size.width - distanza * CGFloat(modello.colonne - 1)) / CGFloat(modello.colonne)
                let altezza = (spazio.size.height - distanza * CGFloat(modello.righe - 1)) / CGFloat(modello.righe)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(larghezza), spacing: distanza), count: modello.colonne),
                          spacing: distanza) {
                    ForEach(modello.carte) { carta in
                        Button { modello.tocca(carta) } label: {
                            CartaView(carta: carta).frame(width: larghezza, height: altezza)
                        }
                        .buttonStyle(StilePremuto())
                        .accessibilityLabel(carta.scoperta || carta.trovata ? "Carta scoperta" : "Carta coperta")
                    }
                }
                .frame(width: spazio.size.width, height: spazio.size.height)
            }

            HStack(spacing: 24) {
                Text(modello.messaggio)
                    .testo(DimensioneTesto.grande)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                BottoneVoce(testo: Istruzioni.coppie, etichetta: "Ascolta come si gioca", altezza: 76)
            }
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }
}

/// Una carta: coperta è blu con un punto interrogativo, scoperta mostra la foto. Si gira come una carta vera.
private struct CartaView: View {
    let carta: Carta
    private var visibile: Bool { carta.scoperta || carta.trovata }
    private let forma = RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous)

    var body: some View {
        ZStack {
            retro.opacity(visibile ? 0 : 1)
            fronte.opacity(visibile ? 1 : 0).rotation3DEffect(.degrees(180), axis: (0, 1, 0))
        }
        .rotation3DEffect(.degrees(visibile ? 180 : 0), axis: (0, 1, 0))
        .animation(.spring(duration: 0.5, bounce: 0.2), value: visibile)
    }

    private var retro: some View {
        forma.fill(Tema.blu)
            .overlay(Text("?").testo(DimensioneTesto.enorme).foregroundStyle(.white))
            .shadow(color: Tema.testo.opacity(0.2), radius: 8, y: 4)
    }

    private var fronte: some View {
        FotoView(foto: carta.foto)
            .clipShape(forma)
            .overlay(forma.stroke(Tema.verde, lineWidth: carta.trovata ? 8 : 0))
            .overlay(alignment: .topTrailing) {
                if carta.trovata {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white, Tema.verde)
                        .padding(10)
                }
            }
            .shadow(color: Tema.testo.opacity(0.2), radius: 8, y: 4)
    }
}
