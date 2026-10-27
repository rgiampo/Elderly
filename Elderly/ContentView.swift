import SwiftUI

/// La prima schermata: il titolo e tre pulsanti enormi. Niente altro.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()

                VStack(spacing: 60) {
                    Titolo()

                    VStack(spacing: 24) {
                        NavigationLink(destination: ChiGiocaView()) {
                            PulsantePrincipale(titolo: "Gioca", altezza: 140)
                        }
                        NavigationLink(destination: UtentiView()) {
                            PulsanteSecondario(titolo: "Utenti", altezza: 120)
                        }
                        NavigationLink(destination: OpzioniView()) {
                            PulsanteSecondario(titolo: "Opzioni", altezza: 120)
                        }
                    }
                    .buttonStyle(StilePremuto())
                    .frame(maxWidth: 640)
                }
                .padding(40)
            }
        }
    }
}

/// "Elderly" in San Francisco Pro grassetto: una copia bianca sotto dà rilievo alle lettere, con un'ombra morbida.
private struct Titolo: View {
    var body: some View {
        Text("Elderly")
            .font(.system(size: 150, weight: .bold))
            .tracking(-2)
            .foregroundStyle(Tema.testo)
            .background(alignment: .center) {
                Text("Elderly")
                    .font(.system(size: 150, weight: .bold))
                    .tracking(-2)
                    .foregroundStyle(.white.opacity(0.85))
                    .offset(y: 7)
            }
            .shadow(color: Tema.testo.opacity(0.28), radius: 16, y: 14)
            .lineLimit(1).minimumScaleFactor(0.5)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
