import SwiftUI

struct FigureImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Ricorda le figure",
            descrizione: "Guarda bene la figura, poi riconoscila tra altre simili.",
            istruzioni: Istruzioni.figure,
            anteprima: { difficolta in
                HStack(spacing: 16) {
                    ForEach([Figura.rombo, .quadrato, .romboSchiacciato, .parallelogramma].prefix(difficolta.scelteFigure), id: \.self) { figura in
                        figura.disegno(spessore: 7, colore: figura == .rombo ? .white : Tema.testo)
                            .padding(16)
                            .background(figura == .rombo ? Tema.verde : Tema.carta, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
                .frame(maxHeight: 220)
                .animation(.spring(duration: 0.4), value: difficolta)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Una figura da riconoscere tra \(difficolta.scelteFigure)")
            },
            partita: { difficolta in
                FigureView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}
