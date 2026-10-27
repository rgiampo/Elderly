import SwiftUI

/// Poche scelte, per chi accompagna il gioco.
struct OpzioniView: View {
    @AppStorage("suoniAttivi") private var suoniAttivi = true

    var body: some View {
        Form {
            Section {
                Toggle("Suoni", isOn: $suoniAttivi)
            } footer: {
                Text("Spegne le note e i suoni di festa. La voce che legge le domande resta attiva.")
            }
        }
        .font(.system(.title2, design: .rounded))
        .scrollContentBackground(.hidden)
        .background(SfondoCielo())
        .navigationTitle("Opzioni")
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { OpzioniView() }
}
