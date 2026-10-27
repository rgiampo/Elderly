import SwiftUI

/// La schermata prima di ogni gioco: a sinistra cos'è e come si gioca, a destra la difficoltà e "Giochiamo!".
/// Tutta in una schermata, senza scorrere. Ogni gioco mette l'anteprima e la partita.
struct ImpostazioniGiocoView<Anteprima: View, Partita: View>: View {
    let titolo: String
    let descrizione: String
    let istruzioni: String
    var livelli: [Difficolta] = [.facile, .medio, .difficile]
    @ViewBuilder let anteprima: (Difficolta) -> Anteprima
    @ViewBuilder let partita: (Difficolta) -> Partita

    @State private var difficolta = Difficolta.facile

    var body: some View {
        ZStack {
            SfondoCielo()

            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(descrizione)
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .fixedSize(horizontal: false, vertical: true)

                    anteprima(difficolta)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(24)
                        .scheda()

                    BottoneVoce(testo: istruzioni, etichetta: "Ascolta come si gioca")
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 16) {
                    Text("Difficoltà")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testoSecondario)
                    ForEach(livelli) { livello in
                        Button { difficolta = livello } label: {
                            Text(livello.nome)
                                .testo(DimensioneTesto.grande)
                                .foregroundStyle(difficolta == livello ? .white : Tema.testo)
                                .lineLimit(1).minimumScaleFactor(0.5)
                                .frame(maxWidth: .infinity, minHeight: 96)
                                .vetro(difficolta == livello ? Tema.blu : .white.opacity(0.78))
                        }
                        .buttonStyle(StilePremuto())
                        .accessibilityAddTraits(difficolta == livello ? .isSelected : [])
                    }
                    Spacer(minLength: 0)
                    NavigationLink(destination: partita(difficolta)) {
                        PulsantePrincipale(titolo: "Giochiamo!", colore: Tema.verde, altezza: 130)
                    }
                    .buttonStyle(StilePremuto())
                }
                .frame(width: 420)
            }
            .padding(.horizontal, 40).padding(.bottom, 32)
        }
        .conIndietro(titolo: titolo)
    }
}
