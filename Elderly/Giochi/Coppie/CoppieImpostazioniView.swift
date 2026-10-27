import SwiftUI

/// Prima di "Trova le coppie": quante carte ci sono e la scelta del livello.
struct CoppieImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Trova le coppie",
            descrizione: "Gira due carte alla volta e trova le foto uguali. Ricorda dove sono!",
            istruzioni: Istruzioni.coppie,
            anteprima: { difficolta in
                VStack(spacing: 22) {
                    IllustrazioneCoppia(conCarteCoperte: false)
                        .frame(maxHeight: .infinity)
                    // quante carte ci sono col livello scelto
                    Text("\(difficolta.numeroCoppie * 2) carte, \(difficolta.numeroCoppie) coppie da trovare")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .contentTransition(.numericText())
                }
                .animation(.spring(duration: 0.4), value: difficolta)
            },
            partita: { difficolta in
                CoppieGiocoView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}
