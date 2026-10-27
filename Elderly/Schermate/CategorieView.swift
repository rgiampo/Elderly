import SwiftUI

/// Scelta della categoria di gioco. Ogni categoria è una scheda grande.
struct CategorieView: View {
    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(spacing: 28) {
                    HStack {
                        Text("Scegli un gioco")
                            .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                            .foregroundStyle(Tema.testo)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        ChipUtente()
                    }

                    NavigationLink(destination: FormeImpostazioniView()) {
                        SchedaCategoria(titolo: "Abilità mentali") {
                            HStack(spacing: 10) {
                                ForEach([Forma.triangolo, .cerchio, .quadrato], id: \.self) { forma in
                                    forma.sagoma.fill(forma.colore).frame(width: 56, height: 56)
                                }
                            }
                        }
                    }

                    NavigationLink(destination: QuizCucinaView()) {
                        SchedaCategoria(titolo: "Cucina") {
                            HStack(spacing: 10) {
                                ForEach(["🍕", "🍝", "🧀"], id: \.self) { Text($0).font(.system(size: 56)) }
                            }
                        }
                    }
                }
                .buttonStyle(StilePremuto())
                .padding(40)
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Anteprima a sinistra, titolo e freccia a destra, come nel mockup.
struct SchedaCategoria<Anteprima: View>: View {
    let titolo: String
    @ViewBuilder let anteprima: Anteprima

    var body: some View {
        HStack(spacing: 32) {
            anteprima.frame(width: 260)
            Text(titolo)
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right").font(.system(size: 40, weight: .bold))
        }
        .foregroundStyle(Tema.testo)
        .padding(32)
        .frame(minHeight: 200)
        .scheda(raggio: 40)
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { CategorieView() }
}
