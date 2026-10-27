import SwiftUI

/// Prima di "Suona le forme": si sceglie la difficoltà e si parte.
struct FormeImpostazioniView: View {
    @Environment(Sessione.self) private var sessione
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
                            .testo(DimensioneTesto.grande, .medium)
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
                        GiocoView(giocatori: sessione.giocatori, difficolta: difficolta)
                    } label: {
                        Text("Giochiamo!")
                            .testo(DimensioneTesto.titolo, .heavy)
                            .foregroundStyle(.white)
                            .frame(maxWidth: 560, minHeight: 110)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Tema.azzurroProfondo)

                    // tre pulsanti grandi al posto del selettore piccolo di sistema
                    HStack(spacing: 20) {
                        ForEach(Difficolta.allCases) { livello in
                            Button { difficolta = livello } label: {
                                Text(livello.nome)
                                    .testo(DimensioneTesto.medio, .heavy)
                                    .foregroundStyle(difficolta == livello ? .white : Tema.testo)
                                    .frame(minWidth: 200, minHeight: 80)
                            }
                            .buttonStyle(.glassProminent)
                            .tint(difficolta == livello ? Tema.azzurroProfondo : .white)
                            .accessibilityAddTraits(difficolta == livello ? .isSelected : [])
                        }
                    }
                }
                .padding(40)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { FormeImpostazioniView() }
        .environment(Sessione())
}
