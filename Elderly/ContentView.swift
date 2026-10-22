import SwiftUI

struct ContentView: View {
    @State private var giocatori = 2
    @State private var difficolta = Difficolta.facile

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Suona le forme")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("Ripetiamo insieme la melodia")
                    .font(.system(size: 36, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack(spacing: 24) {
                    ForEach(Forma.allCases) { forma in
                        forma.sagoma.fill(forma.colore.gradient).frame(width: 90, height: 90)
                    }
                }

                // Scelte per chi accompagna il gioco
                VStack(spacing: 20) {
                    Stepper("Giocatori: \(giocatori)", value: $giocatori, in: 1...6)
                        .font(.system(size: 32, design: .rounded))
                    Picker("Difficoltà", selection: $difficolta) {
                        ForEach(Difficolta.allCases) { Text($0.nome).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.extraLarge)
                }
                .frame(maxWidth: 520)

                NavigationLink {
                    GiocoView(giocatori: giocatori, difficolta: difficolta)
                        .navigationBarBackButtonHidden(false)
                } label: {
                    Text("Giochiamo!")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .padding(.horizontal, 80).padding(.vertical, 28)
                        .foregroundStyle(.white)
                        .background(Color.blue.gradient, in: Capsule())
                }
            }
            .padding(40)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
