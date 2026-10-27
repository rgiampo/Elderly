import SwiftUI

struct FormeImpostazioniView: View {
    @State private var giocatori = 2
    @State private var difficolta = Difficolta.facile
    @ScaledMetric(relativeTo: .largeTitle) private var titolo = 88
    @ScaledMetric(relativeTo: .largeTitle) private var miniatura = 92

    var body: some View {
        ZStack {
                SfondoCielo()

                ScrollView {
                    VStack(spacing: 36) {
                        VStack(spacing: 8) {
                            Text("Suona le forme")
                                .font(.system(size: titolo, weight: .heavy, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .accessibilityAddTraits(.isHeader)
                            Text("Ripetiamo insieme la melodia")
                                .font(.system(.title, design: .rounded, weight: .medium))
                                .foregroundStyle(Tema.testoSecondario)
                        }
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Tema.testo)

                        HStack(spacing: 24) {
                            ForEach(Forma.allCases) { forma in
                                Color.clear
                                    .frame(width: miniatura, height: miniatura)
                                    .glassEffect(.regular.tint(forma.colore), in: forma.sagoma)
                            }
                        }
                        .accessibilityHidden(true)

                        BottoneVoce(testo: Istruzioni.comeSiGioca)
                            .frame(maxWidth: 860)

                        NavigationLink {
                            GiocoView(giocatori: giocatori, difficolta: difficolta)
                        } label: {
                            Text("Giochiamo!")
                                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(maxWidth: 560, minHeight: 110)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Tema.azzurroProfondo)

                        ScelteDiPartita(giocatori: $giocatori, difficolta: $difficolta)
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity)
                }
        }
    }
}

/// Per chi accompagna il gioco: controlli nativi, quindi VoiceOver e Dynamic Type funzionano da soli.
struct ScelteDiPartita: View {
    @Binding var giocatori: Int
    @Binding var difficolta: Difficolta

    var body: some View {
        VStack(spacing: 20) {
            Stepper(value: $giocatori, in: 1...6) {
                Text(giocatori == 1 ? "1 giocatore" : "\(giocatori) giocatori")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
            }
            Picker("Difficoltà", selection: $difficolta) {
                ForEach(Difficolta.allCases) { Text($0.nome).tag($0) }
            }
            .pickerStyle(.segmented)
            .controlSize(.extraLarge)
        }
        .foregroundStyle(Tema.testo)
        .padding(28)
        .frame(maxWidth: 600)
        .glassEffect(.regular, in: .rect(cornerRadius: 36))
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { FormeImpostazioniView() }
}
