import SwiftUI

struct CosaMancaImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Cosa manca?",
            descrizione: "Guarda bene le foto: una sparirà. Riesci a dire quale?",
            istruzioni: Istruzioni.cosaManca,
            anteprima: { difficolta in
                let foto = ["foto_gatto", "foto_pizza", "foto_arancia", "foto_cane", "foto_limone", "foto_uva"]
                let colonne = difficolta.fotoCosaManca == 4 ? 2 : 3
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: colonne), spacing: 14) {
                    ForEach(0..<difficolta.fotoCosaManca, id: \.self) { numero in
                        Group {
                            if numero == 1 {
                                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Tema.blu)
                                    .overlay(Text("?").testo(DimensioneTesto.grande).foregroundStyle(.white))
                            } else {
                                FotoView(foto: .risorsa(foto[numero]), intera: true)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }
                        .aspectRatio(Configurazione.formaFoto, contentMode: .fit)
                    }
                }
                .animation(.spring(duration: 0.4), value: difficolta)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(difficolta.fotoCosaManca) foto, una sparisce")
            },
            partita: { difficolta in
                CosaMancaView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}
