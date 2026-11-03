import SwiftUI
import SwiftData

/// Le partite di una persona, dalla più recente. I giochi per la mente stanno in alto, a parte.
struct RisultatiUtenteView: View {
    let utente: Utente

    private var ordinati: [Risultato] { utente.risultati.sorted { $0.data > $1.data } }
    private var mente: [Risultato] { ordinati.filter { $0.gioco?.categoria == .mente } }
    private var altri: [Risultato] { ordinati.filter { $0.gioco?.categoria != .mente } }

    var body: some View {
        ZStack {
            SfondoCielo()

            if ordinati.isEmpty {
                Text("\(utente.nome) non ha ancora finito una partita.")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testo)
                    .multilineTextAlignment(.center)
                    .padding(40)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        sezione("Giochi per la mente", mente)
                        sezione("Altri giochi", altri)
                    }
                    .padding(.horizontal, 40).padding(.bottom, 32)
                    .frame(maxWidth: 1100)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .conIndietro(titolo: utente.nomeCompleto)
    }

    @ViewBuilder private func sezione(_ titolo: String, _ risultati: [Risultato]) -> some View {
        if !risultati.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(titolo)
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
                ForEach(risultati) { RigaRisultato(risultato: $0) }
            }
        }
    }
}

/// Una partita: il gioco e il giorno a sinistra, il punteggio grande a destra.
private struct RigaRisultato: View {
    let risultato: Risultato

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(risultato.gioco?.titolo ?? "Gioco")
                    .testo(DimensioneTesto.medio)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text("\(risultato.data.formatted(.dateTime.day().month(.wide).year())), \(risultato.data.formatted(date: .omitted, time: .shortened))")
                    .testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
                    .lineLimit(1).minimumScaleFactor(0.5)
            }
            Spacer(minLength: 16)
            VStack(alignment: .trailing, spacing: 4) {
                Text(risultato.cosaConta)
                    .testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(risultato.testo)
                    .testo(DimensioneTesto.grande)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(Tema.testo)
        .padding(.horizontal, 28).padding(.vertical, 20)
        .background(Tema.carta, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
        .shadow(color: Tema.testo.opacity(0.12), radius: 10, y: 5)
        .accessibilityElement(children: .combine)
    }
}
