import SwiftUI
import SwiftData

/// Dalla home: l'elenco delle persone, si tocca una persona per vedere le sue partite.
struct RisultatiView: View {
    @Query(sort: \Utente.nome) private var utenti: [Utente]

    var body: some View {
        ZStack {
            SfondoCielo()

            VStack(spacing: 24) {
                if utenti.isEmpty {
                    Text("Non c'è nessuna persona.\nI risultati si salvano per chi gioca con il nome.")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 40)
                    Spacer(minLength: 0)
                } else {
                    ListaAlfabetica(utenti: utenti) { utente in
                        NavigationLink(destination: RisultatiUtenteView(utente: utente)) {
                            RigaUtente(utente: utente) {
                                Text(utente.risultati.count == 1 ? "1 partita" : "\(utente.risultati.count) partite")
                                    .testo(DimensioneTesto.medio)
                                    .foregroundStyle(Tema.testoSecondario)
                                Image(systemName: "chevron.right").font(.system(size: 32, weight: .bold))
                            }
                        }
                        .buttonStyle(StilePremuto())
                    }
                }
            }
            .padding(.horizontal, 40).padding(.bottom, 32)
            .frame(maxWidth: 1100)
        }
        .conIndietro(titolo: "Risultati")
    }
}

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
                Text(risultato.data.formatted(.dateTime.day().month(.wide).year().hour().minute()))
                    .testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
            }
            Spacer(minLength: 0)
            Label(risultato.testo, systemImage: "star.fill")
                .testo(DimensioneTesto.grande)
                .lineLimit(1)
        }
        .foregroundStyle(Tema.testo)
        .padding(.horizontal, 28).padding(.vertical, 20)
        .background(Tema.carta, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
        .shadow(color: Tema.testo.opacity(0.12), radius: 10, y: 5)
        .accessibilityElement(children: .combine)
    }
}
