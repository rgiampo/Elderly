import SwiftUI

/// Scelta del gioco. Due colonne, una per categoria, con schede grandi: tutto visibile, niente scorrimento.
struct GiochiView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ZStack {
            SfondoCielo()

            HStack(alignment: .top, spacing: 32) {
                ForEach(Gioco.Categoria.allCases, id: \.self) { categoria in
                    VStack(spacing: 20) {
                        Text(categoria.rawValue)
                            .testo(DimensioneTesto.medio)
                            .foregroundStyle(Tema.testoSecondario)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(Gioco.allCases.filter { $0.categoria == categoria }) { gioco in
                            NavigationLink(destination: gioco.destinazione) { SchedaGioco(gioco: gioco) }
                                .buttonStyle(StilePremuto())
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            .safeAreaPadding(.bottom, 130)
            .overlay(alignment: .bottom) {
                NavigationLink(destination: GestioneQuizView()) {
                    Text("Crea o modifica quiz")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 84)
                        .scheda()
                }
                .buttonStyle(StilePremuto())
                .padding(.horizontal, 40).padding(.bottom, 28)
            }
        }
        .conIndietro(titolo: "Scegli un gioco") { BarraGiocatori(giocatori: sessione.giocatori) }
    }
}

/// Anteprima in alto, titolo e descrizione sotto. Le due schede di una colonna si dividono lo spazio.
private struct SchedaGioco: View {
    let gioco: Gioco

    var body: some View {
        VStack(spacing: 0) {
            gioco.anteprima
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Tema.celeste.opacity(0.35))

            VStack(spacing: 4) {
                Text(gioco.titolo).testo(DimensioneTesto.grande)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(gioco.descrizione).testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
                    .lineLimit(1).minimumScaleFactor(0.5)
            }
            .foregroundStyle(Tema.testo)
            .padding(.vertical, 16).padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
        .scheda()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(gioco.titolo). \(gioco.descrizione)")
    }
}
