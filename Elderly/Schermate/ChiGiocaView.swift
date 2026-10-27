import SwiftUI
import SwiftData

/// "Chi gioca?": si scelgono una o due persone. Senza scelta si gioca senza nome.
struct ChiGiocaView: View {
    @Environment(Sessione.self) private var sessione
    @Query(sort: \Utente.nome) private var utenti: [Utente]

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Chi gioca?")
                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                            .accessibilityAddTraits(.isHeader)
                        Text("Scegli una o due persone")
                            .font(.system(.title, design: .rounded, weight: .medium))
                            .foregroundStyle(Tema.testoSecondario)
                    }
                    .foregroundStyle(Tema.testo)

                    if utenti.isEmpty {
                        Text("Non ci sono ancora persone. Le aggiungi nella sezione Utenti, oppure puoi giocare senza nome.")
                            .font(.system(.title3, design: .rounded))
                            .foregroundStyle(Tema.testo)
                            .multilineTextAlignment(.center)
                            .padding(24)
                            .scheda()
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 230), spacing: 24)], spacing: 24) {
                        ForEach(utenti) { utente in
                            Button { sessione.alterna(utente) } label: {
                                CartaPersona(utente: utente,
                                             posto: posto(di: utente),
                                             bloccata: sessione.sceltaPiena && !sessione.èScelto(utente))
                            }
                            .buttonStyle(StilePremuto())
                        }
                    }

                    NavigationLink(destination: CategorieView()) {
                        Text("Avanti")
                            .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 560, minHeight: 110)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Tema.azzurroProfondo)
                }
                .padding(40)
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    /// 1 o 2 se la persona è scelta (l'ordine è l'ordine dei turni), altrimenti nil.
    private func posto(di utente: Utente) -> Int? {
        sessione.scelti.firstIndex { $0.id == utente.id }.map { $0 + 1 }
    }
}

private struct CartaPersona: View {
    let utente: Utente
    let posto: Int?
    let bloccata: Bool

    var body: some View {
        VStack(spacing: 12) {
            Avatar(utente: utente, dimensione: 130)
                .overlay(alignment: .topTrailing) {
                    if let posto {
                        Text("\(posto)")
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Tema.azzurroProfondo, in: Circle())
                    }
                }
            Text(utente.nome)
                .font(.system(.title, design: .rounded, weight: .heavy))
        }
        .foregroundStyle(Tema.testo)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .scheda()
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Tema.azzurroProfondo, lineWidth: posto == nil ? 0 : 6))
        .opacity(bloccata ? 0.45 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(utente.nomeCompleto)
        .accessibilityValue(posto.map { "Scelto, numero \($0)" } ?? "Non scelto")
        .accessibilityHint(bloccata ? "Sono già state scelte due persone" : "Tocca per scegliere")
    }
}
