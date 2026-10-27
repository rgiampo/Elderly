import SwiftUI

/// Schermata principale: Gioca, Utenti, Opzioni.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()

                VStack(spacing: 40) {
                    Logo()

                    VStack(spacing: 24) {
                        NavigationLink(destination: CategorieView()) {
                            EtichettaMenu(italiano: "Gioca", inglese: "Play", colore: .white)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Tema.azzurroProfondo)

                        NavigationLink(destination: UtentiView()) {
                            EtichettaMenu(italiano: "Utenti", inglese: "Users")
                        }
                        .buttonStyle(.glass)

                        NavigationLink(destination: OpzioniView()) {
                            EtichettaMenu(italiano: "Opzioni", inglese: "Options")
                        }
                        .buttonStyle(.glass)
                    }
                    .frame(maxWidth: 640)
                }
                .padding(40)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
