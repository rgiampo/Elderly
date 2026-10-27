import SwiftUI

/// "Cosa manca?": sopra le foto (una sparisce), sotto il pulsante "Ho guardato" oppure le due foto tra cui scegliere.
struct CosaMancaView: View {
    @State private var modello: CosaMancaModello
    @Environment(\.dismiss) private var chiudi

    init(giocatori: [Partecipante], difficolta: Difficolta) {
        _modello = State(initialValue: CosaMancaModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            SfondoCielo()
            if modello.finito {
                RisultatoPartitaView(
                    giocatori: modello.giocatori, punti: modello.punti,
                    sommario: modello.giocatori.count > 1
                        ? "Insieme: \(modello.puntiTotali) foto riconosciute su \(modello.totale)"
                        : "Foto riconosciute al primo colpo: \(modello.puntiTotali) su \(modello.totale)",
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
        .animation(.spring(duration: 0.5), value: modello.fase)
        .sensoryFeedback(.impact(weight: .heavy), trigger: modello.turno) { _, _ in modello.giocatori.count > 1 }
        .sensoryFeedback(.success, trigger: modello.fase) { _, nuova in nuova == .trovata }
        .sensoryFeedback(.warning, trigger: modello.sbagliate.count) { prima, dopo in dopo > prima }
        .onDisappear { modello.ferma() }
    }

    private var partita: some View {
        VStack(spacing: 16) {
            BannerTurno(giocatori: modello.giocatori, turno: modello.turno, punti: modello.punti)

            Text(titolo)
                .testo(DimensioneTesto.grande)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)

            griglia.frame(maxHeight: .infinity)

            HStack(spacing: 24) {
                if modello.fase == .scegli { scelte } else if modello.fase == .guarda { pulsanteGuardato }
                else { Spacer() }
                BottoneVoce(testo: modello.testoParlato, etichetta: "Ascolta", altezza: 76)
                    .fixedSize()
            }
            .frame(height: 230)
        }
        .padding(.horizontal, 40).padding(.bottom, 24)
    }

    private var titolo: String {
        switch modello.fase {
        case .guarda: "Guarda bene le foto"
        case .scegli: "Quale foto è sparita?"
        case .trovata: "Ecco quella che mancava"
        }
    }

    /// Le foto in una griglia che riempie lo spazio. Al posto di quella sparita c'è una carta blu con "?".
    private var griglia: some View {
        GeometryReader { spazio in
            let colonne = modello.foto.count == 4 ? 4 : 3
            let righe = (modello.foto.count + colonne - 1) / colonne
            let distanza: CGFloat = 20
            let larghezza = (spazio.size.width - distanza * CGFloat(colonne - 1)) / CGFloat(colonne)
            let altezza = (spazio.size.height - distanza * CGFloat(righe - 1)) / CGFloat(righe)
            let lato = min(larghezza, altezza * Configurazione.formaFoto)
            VStack(spacing: distanza) {
                ForEach(0..<righe, id: \.self) { riga in
                    HStack(spacing: distanza) {
                        ForEach(0..<colonne, id: \.self) { colonna in
                            let numero = riga * colonne + colonna
                            if numero < modello.foto.count { carta(numero).frame(width: lato, height: lato / Configurazione.formaFoto) }
                        }
                    }
                }
            }
            .frame(width: spazio.size.width, height: spazio.size.height)
        }
    }

    @ViewBuilder private func carta(_ numero: Int) -> some View {
        let forma = RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous)
        if numero == modello.posizioneMancante && modello.fase == .scegli {
            forma.fill(Tema.blu)
                .overlay(Text("?").testo(DimensioneTesto.enorme).foregroundStyle(.white))
                .shadow(color: Tema.testo.opacity(0.2), radius: 8, y: 4)
        } else {
            FotoView(foto: modello.foto[numero], intera: true)
                .clipShape(forma)
                .overlay(forma.stroke(Tema.verde, lineWidth: numero == modello.posizioneMancante && modello.fase == .trovata ? 10 : 0))
                .shadow(color: Tema.testo.opacity(0.2), radius: 8, y: 4)
        }
    }

    private var pulsanteGuardato: some View {
        Button { modello.hoGuardato() } label: {
            PulsantePrincipale(titolo: "Ho guardato", colore: Tema.verde, altezza: 130)
        }
        .buttonStyle(StilePremuto())
    }

    /// Le due foto tra cui scegliere: quella sparita e un'altra che non c'era.
    private var scelte: some View {
        HStack(spacing: 24) {
            ForEach(modello.scelte, id: \.self) { foto in
                Button { modello.scegli(foto) } label: {
                    FotoView(foto: foto, intera: true)
                        .aspectRatio(Configurazione.formaFoto, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
                        .shadow(color: Tema.testo.opacity(0.2), radius: 8, y: 4)
                        .saturation(modello.sbagliate.contains(foto) ? 0 : 1)
                        .opacity(modello.sbagliate.contains(foto) ? 0.4 : 1)
                }
                .buttonStyle(StilePremuto())
                .accessibilityLabel("Foto")
            }
        }
    }
}
