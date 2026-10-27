import SwiftUI

struct ProverbiImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Completa il proverbio",
            descrizione: "Leggi l'inizio del proverbio e scegli come finisce.",
            istruzioni: Istruzioni.proverbi,
            anteprima: { difficolta in
                VStack(spacing: 16) {
                    Text("Chi dorme …")
                        .testo(DimensioneTesto.titolo)
                        .foregroundStyle(Tema.testo)
                    ForEach(0..<difficolta.opzioniProverbi, id: \.self) { numero in
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(numero == 0 ? Tema.verde : Tema.celeste.opacity(0.7))
                            .frame(height: 64)
                            .overlay(Text(["non piglia pesci", "vive cent'anni", "mangia sempre bene"][numero])
                                .testo(DimensioneTesto.normale)
                                .foregroundStyle(numero == 0 ? .white : Tema.testo))
                    }
                }
                .animation(.spring(duration: 0.4), value: difficolta)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Un proverbio con \(difficolta.opzioniProverbi) finali tra cui scegliere")
            },
            partita: { difficolta in
                ProverbiView(giocatori: sessione.giocatori, difficolta: difficolta)
            })
    }
}
