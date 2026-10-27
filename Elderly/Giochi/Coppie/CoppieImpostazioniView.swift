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
                let carte = difficolta.numeroCoppie * 2
                let colonne = carte > 8 ? 4 : carte / 2
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: colonne), spacing: 16) {
                    ForEach(0..<carte, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Tema.blu)
                            .aspectRatio(1.2, contentMode: .fit)
                            .overlay(Text("?").testo(DimensioneTesto.grande).foregroundStyle(.white))
                    }
                }
                .animation(.spring(duration: 0.4), value: difficolta)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(carte) carte")
            },
            partita: { difficolta in
                CoppieGiocoView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}
