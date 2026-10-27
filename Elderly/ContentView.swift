import SwiftUI

/// La prima schermata: Gioca, Utenti, Opzioni. Tre pulsanti enormi, al centro.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()

                VStack(spacing: 28) {
                    NavigationLink(destination: ChiGiocaView()) {
                        PulsantePrincipale(titolo: "Gioca", altezza: 150)
                    }
                    NavigationLink(destination: UtentiView()) {
                        PulsanteSecondario(titolo: "Utenti", altezza: 150)
                    }
                    NavigationLink(destination: OpzioniView()) {
                        PulsanteSecondario(titolo: "Opzioni", altezza: 150)
                    }
                }
                .buttonStyle(StilePremuto())
                .frame(maxWidth: 720)
                .padding(40)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
