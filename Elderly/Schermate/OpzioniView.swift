import SwiftUI
import AVFoundation

/// Poche scelte, per chi accompagna il gioco.
struct OpzioniView: View {
    @AppStorage("suoniAttivi") private var suoniAttivi = true
    @AppStorage(Voce.chiaveVoceScelta) private var voceScelta = ""
    @State private var voce = Voce()

    private let voci = Voce.vociItaliane()

    var body: some View {
        Form {
            Section {
                Toggle("Suoni", isOn: $suoniAttivi)
            } footer: {
                Text("Spegne le note e i suoni di festa. La voce che legge le domande resta attiva.")
            }

            Section {
                Picker("Voce", selection: $voceScelta) {
                    Text("Automatica (la migliore)").tag("")
                    ForEach(voci, id: \.identifier) { Text(Voce.descrizione(della: $0)).tag($0.identifier) }
                }
                Button("Prova la voce", systemImage: "speaker.wave.2") {
                    voce.leggi("Ciao! Questa è la voce che leggerà le domande del quiz.")
                }
            } header: {
                Text("Voce che legge")
            } footer: {
                Text("Per una voce più naturale: Impostazioni, Accessibilità, Contenuto letto, Voci, Italiano. Scarica una voce con qualità alta o migliorata, poi torna qui.")
            }
        }
        .testo(DimensioneTesto.medio)
        .scrollContentBackground(.hidden)
        .background(SfondoCielo())
        .safeAreaInset(edge: .top) {
            Text("Opzioni")
                .testo(DimensioneTesto.titolo, .heavy)
                .foregroundStyle(Tema.testo)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40).padding(.top, 8)
                .accessibilityAddTraits(.isHeader)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { voce.ferma() }
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { OpzioniView() }
}
