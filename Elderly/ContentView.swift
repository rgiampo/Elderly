import SwiftUI

/// La prima schermata: il logo, il titolo e tre pulsanti enormi. All'apertura tutto entra in sequenza.
struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @State private var entrato = false

    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()
                DecorazioniHome()

                VStack(spacing: 40) {
                    Titolo(entrato: entrato)

                    VStack(spacing: 20) {
                        NavigationLink(destination: ChiGiocaView()) {
                            PulsantePrincipale(titolo: "Gioca", altezza: 130)
                        }
                        .appari(entrato, ritardo: 0.35)
                        NavigationLink(destination: UtentiView()) {
                            PulsanteSecondario(titolo: "Utenti", altezza: 110)
                        }
                        .appari(entrato, ritardo: 0.5)
                        NavigationLink(destination: OpzioniView()) {
                            PulsanteSecondario(titolo: "Opzioni", altezza: 110)
                        }
                        .appari(entrato, ritardo: 0.65)
                    }
                    .buttonStyle(StilePremuto())
                    .frame(maxWidth: 640)
                }
                .padding(40)
            }
        }
        .onAppear {
            if pocoMovimento { entrato = true } else { withAnimation { entrato = true } }
        }
    }
}

extension View {
    /// Entra dal basso e diventa visibile, con un piccolo ritardo (per far comparire le cose una dopo l'altra).
    fileprivate func appari(_ entrato: Bool, ritardo: Double) -> some View {
        opacity(entrato ? 1 : 0)
            .offset(y: entrato ? 0 : 40)
            .animation(.spring(duration: 0.7, bounce: 0.3).delay(ritardo), value: entrato)
    }
}

/// Il logo, che respira piano, e il nome dell'app in San Francisco bold con un'ombra leggera.
private struct Titolo: View {
    let entrato: Bool
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @State private var respira = false

    var body: some View {
        VStack(spacing: 14) {
            Image("Logo")
                .resizable().scaledToFill()
                .frame(width: 190, height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                .shadow(color: Tema.testo.opacity(0.3), radius: 18, y: 12)
                .scaleEffect(entrato ? (respira ? 1.04 : 1) : 0.4)
                .rotationEffect(.degrees(entrato ? 0 : -12))
                .opacity(entrato ? 1 : 0)
                .animation(.spring(duration: 0.8, bounce: 0.45), value: entrato)
                .animation(pocoMovimento ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true), value: respira)
                .accessibilityHidden(true)

            Text("Elderly")
                .font(.system(size: 130, weight: .bold))
                .tracking(-2)
                .foregroundStyle(Tema.testo)
                .shadow(color: Tema.testo.opacity(0.22), radius: 14, y: 10)
                .lineLimit(1).minimumScaleFactor(0.5)
                .opacity(entrato ? 1 : 0)
                .offset(y: entrato ? 0 : 30)
                .animation(.spring(duration: 0.7, bounce: 0.3).delay(0.2), value: entrato)
                .accessibilityAddTraits(.isHeader)
        }
        .onAppear { respira = true }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
