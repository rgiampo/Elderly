import SwiftUI

/// La prima schermata: il titolo e tre pulsanti enormi. Niente altro.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()

                VStack(spacing: 40) {
                    Titolo()

                    VStack(spacing: 20) {
                        NavigationLink(destination: ChiGiocaView()) {
                            PulsantePrincipale(titolo: "Gioca", altezza: 130)
                        }
                        NavigationLink(destination: UtentiView()) {
                            PulsanteSecondario(titolo: "Utenti", altezza: 110)
                        }
                        NavigationLink(destination: OpzioniView()) {
                            PulsanteSecondario(titolo: "Opzioni", altezza: 110)
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

/// Logo e nome dell'app: il logo è un quadrato morbido come un'icona, il nome è San Francisco bold con un'ombra leggera.
private struct Titolo: View {
    var body: some View {
        VStack(spacing: 14) {
            Image("Logo")
                .resizable().scaledToFill()
                .frame(width: 190, height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                .shadow(color: Tema.testo.opacity(0.3), radius: 18, y: 12)
                .accessibilityHidden(true)

            Text("Elderly")
                .font(.system(size: 130, weight: .bold))
                .tracking(-2)
                .foregroundStyle(LinearGradient(colors: [Color(red: 0.26, green: 0.16, blue: 0.11), Tema.testo],
                                                startPoint: .top, endPoint: .bottom))
                .shadow(color: Tema.testo.opacity(0.22), radius: 14, y: 10)
                .lineLimit(1).minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
