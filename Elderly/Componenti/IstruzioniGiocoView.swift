import SwiftUI

/// Schermata prima di un gioco senza difficoltà: spiega come si gioca in pochi passi, poi "Giochiamo!".
struct IstruzioniGiocoView<Partita: View>: View {
    let titolo: String
    let descrizione: String
    let passi: [String]
    let voce: String
    @ViewBuilder let partita: () -> Partita
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ZStack {
            SfondoCielo()

            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(descrizione)
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 28) {
                        ForEach(Array(passi.enumerated()), id: \.offset) { numero, passo in
                            HStack(spacing: 24) {
                                Text("\(numero + 1)")
                                    .testo(DimensioneTesto.grande)
                                    .foregroundStyle(.white)
                                    .frame(width: 88, height: 88)
                                    .background(Tema.blu, in: Circle())
                                Text(passo)
                                    .testo(DimensioneTesto.medio)
                                    .foregroundStyle(Tema.testo)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Text("Non c'è fretta e non si perde mai.")
                            .testo(DimensioneTesto.normale)
                            .foregroundStyle(Tema.testoSecondario)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(32)
                    .scheda()

                    BottoneVoce(testo: voce, etichetta: "Ascolta come si gioca")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Spacer(minLength: 0)
                    NavigationLink(destination: partita()) {
                        PulsantePrincipale(titolo: "Giochiamo!", colore: Tema.verde, altezza: 130)
                    }
                    .buttonStyle(StilePremuto())
                }
                .frame(width: 420)
            }
            .padding(.horizontal, 40).padding(.bottom, 32)
        }
        .conIndietro(titolo: titolo) { BarraGiocatori(giocatori: sessione.giocatori) }
    }
}
