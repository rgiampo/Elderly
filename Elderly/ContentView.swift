import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 24)], spacing: 24) {
                    ForEach(Gioco.catalogo) { gioco in
                        NavigationLink {
                            gioco.vista()
                        } label: {
                            SchedaGiocoView(gioco: gioco)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(32)
            }
            .navigationTitle("Elderly")
        }
    }
}

struct SchedaGiocoView: View {
    let gioco: Gioco

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: gioco.icona).font(.system(size: 64))
            Text(gioco.titolo).font(.largeTitle.bold())
            Text(gioco.descrizione).font(.title3)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(gioco.colore.gradient, in: RoundedRectangle(cornerRadius: 28))
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
