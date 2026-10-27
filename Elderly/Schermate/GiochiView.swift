import SwiftUI

/// Prima scelta: tre grandi pulsanti, uno sotto l'altro. Niente altro sullo schermo.
struct GiochiView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ZStack {
            SfondoCielo()

            VStack(spacing: 24) {
                ForEach(Array(Categoria.allCases.enumerated()), id: \.element) { posizione, categoria in
                    NavigationLink(destination: destinazione(categoria)) {
                        RigaCategoria(categoria: categoria)
                    }
                    .buttonStyle(StilePremuto())
                }
            }
            .padding(.horizontal, 60).padding(.bottom, 40)
            .frame(maxWidth: 1100)
        }
        .conIndietro(titolo: "Scegli") { BarraGiocatori(giocatori: sessione.giocatori) }
    }

    @ViewBuilder private func destinazione(_ categoria: Categoria) -> some View {
        switch categoria {
        case .crea: GestioneQuizView()
        default: GiochiDellaCategoriaView(categoria: categoria)
        }
    }
}

/// Un pulsante: le immagini a sinistra, il titolo grande e la freccia. Tutta la riga si tocca.
private struct RigaCategoria: View {
    let categoria: Categoria

    var body: some View {
        HStack(spacing: 32) {
            categoria.anteprima
                .frame(width: 330, height: 130)
            Text(categoria.titolo)
                .testo(DimensioneTesto.grande)
                .lineLimit(2).minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right").font(.system(size: 40, weight: .bold))
        }
        .foregroundStyle(Tema.testo)
        .padding(.horizontal, 32).padding(.vertical, 20)
        .frame(maxHeight: .infinity)
        .scheda()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(categoria.titolo)
    }
}

/// Seconda scelta: i giochi di una categoria, due schede per riga, tutte della stessa grandezza e senza scorrere.
struct GiochiDellaCategoriaView: View {
    let categoria: Categoria
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ZStack {
            SfondoCielo()

            Grid(horizontalSpacing: 32, verticalSpacing: 28) {
                ForEach(Array(righe.enumerated()), id: \.offset) { numeroRiga, riga in
                    GridRow {
                        ForEach(Array(riga.enumerated()), id: \.element) { colonna, gioco in
                            NavigationLink(destination: gioco.destinazione) { SchedaGioco(gioco: gioco) }
                                .buttonStyle(StilePremuto())
                        }
                    }
                }
            }
            .padding(.horizontal, 60).padding(.bottom, 40)
        }
        .conIndietro(titolo: categoria.titolo) { BarraGiocatori(giocatori: sessione.giocatori) }
    }

    /// I giochi a due a due.
    private var righe: [[Gioco]] {
        stride(from: 0, to: categoria.giochi.count, by: 2).map { Array(categoria.giochi[$0..<min($0 + 2, categoria.giochi.count)]) }
    }
}

/// Anteprima in alto, titolo e descrizione sotto. Tutta la scheda si tocca.
private struct SchedaGioco: View {
    let gioco: Gioco

    var body: some View {
        VStack(spacing: 0) {
            gioco.anteprima
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            VStack(spacing: 10) {
                Text(gioco.titolo).testo(DimensioneTesto.grande)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(gioco.descrizione).testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
                    .lineLimit(1).minimumScaleFactor(0.5)
            }
            .foregroundStyle(Tema.testo)
            .padding(.vertical, 28).padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
        .scheda()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(gioco.titolo). \(gioco.descrizione)")
    }
}
