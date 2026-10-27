import SwiftUI
import AVFoundation

/// Poche scelte, per chi accompagna il gioco.
struct OpzioniView: View {
    @AppStorage("suoniAttivi") private var suoniAttivi = true
    @AppStorage(Grandezza.chiaveTesto) private var grandezzaTesto = Grandezza.media.rawValue
    @AppStorage(Grandezza.chiaveFoto) private var grandezzaFoto = Grandezza.grande.rawValue
    @AppStorage(Voce.chiaveVoceScelta) private var voceScelta = ""
    @State private var voce = Voce()

    private let voci = Voce.vociItaliane()

    var body: some View {
        ZStack {
            SfondoCielo()

            Form {
                Section("Grandezza dei testi") { scelta($grandezzaTesto) }
                Section("Grandezza delle foto") { scelta($grandezzaFoto) }

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
                    VStack(alignment: .leading, spacing: 8) {
                        if Voce.èVoceDiQualitàInstallata {
                            Label("Sul tablet c'è una voce di qualità alta: la usiamo noi.", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Tema.verde)
                        } else {
                            Label("Sul tablet c'è solo la voce di base, che suona più robotica.", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(Tema.rosso)
                            Text("Per una voce molto più naturale: Impostazioni, Accessibilità, Contenuto letto, Voci, Italiano, poi scarica una voce \"Migliorata\" o \"Premium\" (per esempio Alice o Luca). Torna qui e viene usata da sola.")
                        }
                    }
                }
            }
            .testo(DimensioneTesto.normale)
            .scrollContentBackground(.hidden)
        }
        .conIndietro(titolo: "Opzioni")
        .onDisappear { voce.ferma() }
    }
}

extension OpzioniView {
    /// Tre pulsanti grandi: Piccola, Media, Grande. Quello scelto è pieno di colore.
    fileprivate func scelta(_ valore: Binding<String>) -> some View {
        HStack(spacing: 12) {
            ForEach(Grandezza.allCases) { opzione in
                Button { valore.wrappedValue = opzione.rawValue } label: {
                    Text(opzione.nome)
                        .testo(DimensioneTesto.normale)
                        .foregroundStyle(valore.wrappedValue == opzione.rawValue ? .white : Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 76)
                        .background(valore.wrappedValue == opzione.rawValue ? Tema.blu : Tema.celeste.opacity(0.45),
                                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(valore.wrappedValue == opzione.rawValue ? .isSelected : [])
            }
        }
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
