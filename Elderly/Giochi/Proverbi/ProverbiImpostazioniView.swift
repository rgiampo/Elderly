import SwiftUI

struct ProverbiImpostazioniView: View {
    @Environment(Sessione.self) private var sessione

    var body: some View {
        ImpostazioniGiocoView(
            titolo: "Completa il proverbio",
            descrizione: "Leggi l'inizio del proverbio e scegli come finisce.",
            istruzioni: Istruzioni.proverbi,
            anteprima: { difficolta in
                // come nel gioco: con tre o quattro fini, due per riga (così l'anteprima resta bassa e "Giochiamo!" si vede)
                let numero = difficolta.opzioniProverbi
                let perRiga = numero > 2 ? 2 : 1
                VStack(spacing: 14) {
                    Text("Chi dorme …")
                        .testo(DimensioneTesto.titolo)
                        .foregroundStyle(Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: perRiga), spacing: 12) {
                        ForEach(0..<numero, id: \.self) { n in
                            Text(["non piglia pesci", "vive cent'anni", "mangia sempre bene", "va sano e va lontano"][n])
                                .testo(DimensioneTesto.normale)
                                .foregroundStyle(n == 0 ? .white : Tema.testo)
                                .lineLimit(1).minimumScaleFactor(0.5)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(n == 0 ? Tema.verde : Tema.celeste.opacity(0.7), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
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
