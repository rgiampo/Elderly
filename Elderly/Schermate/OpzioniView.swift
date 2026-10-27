import SwiftUI
import AVFoundation

/// Poche scelte, per chi accompagna il gioco.
struct OpzioniView: View {
    @AppStorage("suoniAttivi") private var suoniAttivi = true
    @AppStorage(Voce.chiaveVoceScelta) private var voceScelta = ""
    @State private var voce = Voce()

    private let voci = Voce.vociItaliane()

    var body: some View {
        ZStack {
            SfondoCielo()

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
                    BottoneVoceProva(voce: voce)
                } header: {
                    Text("Voce che legge")
                } footer: {
                    Text("Per una voce più naturale: Impostazioni, Accessibilità, Contenuto letto, Voci, Italiano. Scarica una voce di qualità alta, poi torna qui.")
                }
            }
            .testo(DimensioneTesto.normale)
            .scrollContentBackground(.hidden)
        }
        .conIndietro(titolo: "Opzioni")
        .onDisappear { voce.ferma() }
    }
}

/// "Prova la voce": un pulsante come gli altri dell'app (senza icone di sistema nelle liste, che si vedevano male).
private struct BottoneVoceProva: View {
    let voce: Voce

    var body: some View {
        Button {
            voce.leggi("Ciao! Questa è la voce che leggerà le domande del quiz.")
        } label: {
            Text(voce.staParlando ? "Ferma la voce" : "Prova la voce")
                .testo(DimensioneTesto.normale)
                .foregroundStyle(Tema.blu)
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { OpzioniView() }
}
