import SwiftUI

/// Prima di "Suona le forme": le forme che troverai (più è difficile, più sono) e la scelta del livello.
struct FormeImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Suona le forme",
            descrizione: "Guarda le forme che si accendono e suonano, poi ripetile nello stesso ordine.",
            istruzioni: Istruzioni.forme,
            livelli: Difficolta.allCases,
            anteprima: { difficolta in
                // fino a 5 forme in una riga, il Maestro su due righe da 6: l'anteprima resta bassa
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: min(difficolta.numeroForme, difficolta.numeroForme > 5 ? 6 : 5)), spacing: 20) {
                    ForEach(difficolta.forme) { forma in
                        forma.sagoma.fill(forma.colore)
                            .aspectRatio(1, contentMode: .fit)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(duration: 0.4, bounce: 0.3), value: difficolta)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(difficolta.numeroForme) forme")
            },
            partita: { difficolta in
                FormeGiocoView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}
