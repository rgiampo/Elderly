import SwiftUI
import SwiftData

/// Elenco delle persone. Si tocca una riga per modificarla.
struct UtentiView: View {
    @Query(sort: \Utente.nome) private var utenti: [Utente]
    @State private var nuovoUtente = false

    var body: some View {
        ZStack {
            SfondoCielo()

            VStack(spacing: 24) {
                if utenti.isEmpty {
                    Text("Non c'è nessuna persona.\nTocca il pulsante qui sotto per aggiungerne una.")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 40)
                    Spacer(minLength: 0)
                } else {
                    ListaAlfabetica(utenti: utenti) { utente in
                        NavigationLink(destination: UtenteFormView(utente: utente)) {
                            RigaUtente(utente: utente) {
                                Image(systemName: "chevron.right").font(.system(size: 32, weight: .bold))
                            }
                        }
                        .buttonStyle(StilePremuto())
                    }
                }

                Button { nuovoUtente = true } label: {
                    Label("Aggiungi una persona", systemImage: "plus")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .padding(.horizontal, 44)
                        .frame(minHeight: 76)
                        .vetro(Tema.blu)
                }
                .buttonStyle(StilePremuto())
            }
            .padding(.horizontal, 40).padding(.bottom, 32)
            .frame(maxWidth: 1100)
        }
        .conIndietro(titolo: "Utenti")
        .fullScreenCover(isPresented: $nuovoUtente) {
            NavigationStack { UtenteFormView(utente: nil) }
        }
    }
}

/// Una persona in elenco: foto, nome e cognome su una riga, età. A destra va quello che serve alla schermata.
struct RigaUtente<Accessorio: View>: View {
    let utente: Utente
    @ViewBuilder let accessorio: Accessorio

    var body: some View {
        HStack(spacing: 28) {
            Avatar(utente: utente, dimensione: 110)

            VStack(alignment: .leading, spacing: 4) {
                Text(utente.nomeCompleto)
                    .testo(DimensioneTesto.grande)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text("Età: \(utente.etaAttuale) anni")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
            }

            Spacer(minLength: 0)
            accessorio
        }
        .foregroundStyle(Tema.testo)
        .padding(20)
        .scheda()
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { UtentiView() }
        .modelContainer(for: Utente.self, inMemory: true)
}
