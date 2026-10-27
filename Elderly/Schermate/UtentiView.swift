import SwiftUI
import SwiftData

/// Elenco delle persone. Si tocca una riga per modificarla, "+" per aggiungerne una.
struct UtentiView: View {
    @Query(sort: \Utente.nome) private var utenti: [Utente]
    @State private var nuovoUtente = false

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Utenti")
                        .testo(DimensioneTesto.titolo, .heavy)
                        .foregroundStyle(Tema.testo)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(utenti) { utente in
                        NavigationLink(destination: UtenteFormView(utente: utente)) {
                            RigaUtente(utente: utente)
                        }
                        .buttonStyle(StilePremuto())
                    }

                    if utenti.isEmpty {
                        Text("Nessuna persona. Tocca + per aggiungerne una.")
                            .testo(DimensioneTesto.grande, .semibold)
                            .foregroundStyle(Tema.testo)
                            .padding(.vertical, 40)
                    }

                    Button { nuovoUtente = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 44, weight: .bold))
                            .frame(width: 100, height: 100)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Tema.azzurroProfondo)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Aggiungi una persona")
                    .padding(.top, 12)
                }
                .padding(40)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $nuovoUtente) {
            NavigationStack { UtenteFormView(utente: nil) }
        }
    }
}

struct RigaUtente: View {
    let utente: Utente

    var body: some View {
        HStack(spacing: 28) {
            Avatar(utente: utente, dimensione: 100)

            VStack(alignment: .leading, spacing: 4) {
                Text(utente.nome).testo(DimensioneTesto.grande, .heavy)
                Text(utente.cognome).testo(DimensioneTesto.grande, .heavy)
                Text("Età: \(utente.etaAttuale)").testo(DimensioneTesto.medio)
            }

            Spacer()

            Image(systemName: "chevron.right").font(.system(size: 32, weight: .bold))
        }
        .foregroundStyle(Tema.testo)
        .padding(24)
        .scheda()
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tocca per modificare")
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { UtentiView() }
        .modelContainer(for: Utente.self, inMemory: true)
}
