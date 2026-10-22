import SwiftUI

struct Carta: Identifiable {
    let id = UUID()
    let simbolo: String
    var scoperta = false
    var trovata = false
}

struct GiocoMemoriaView: View {
    private static let simboli = ["sun.max.fill", "leaf.fill", "heart.fill", "star.fill",
                                  "moon.fill", "cloud.fill", "flame.fill", "drop.fill"]

    let coppie: Int
    @State private var carte: [Carta] = []
    @State private var bloccato = false

    private var haiVinto: Bool { !carte.isEmpty && carte.allSatisfy(\.trovata) }

    var body: some View {
        VStack(spacing: 24) {
            if haiVinto {
                Text("Bravissimo!").font(.system(size: 44, weight: .bold))
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                ForEach(carte) { carta in
                    CartaView(carta: carta)
                        .onTapGesture { scopri(carta) }
                }
            }
            Button("Ricomincia", action: nuovaPartita)
                .font(.title)
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .navigationTitle("Memoria")
        .onAppear(perform: nuovaPartita)
    }

    private func nuovaPartita() {
        let scelti = Self.simboli.shuffled().prefix(coppie)
        carte = (scelti + scelti).shuffled().map { Carta(simbolo: $0) }
        bloccato = false
    }

    private func scopri(_ carta: Carta) {
        guard !bloccato, let i = carte.firstIndex(where: { $0.id == carta.id }),
              !carte[i].scoperta, !carte[i].trovata else { return }
        carte[i].scoperta = true

        let scoperte = carte.indices.filter { carte[$0].scoperta }
        guard scoperte.count == 2 else { return }

        if carte[scoperte[0]].simbolo == carte[scoperte[1]].simbolo {
            scoperte.forEach { carte[$0].trovata = true; carte[$0].scoperta = false }
        } else {
            bloccato = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                scoperte.forEach { carte[$0].scoperta = false }
                bloccato = false
            }
        }
    }
}

struct CartaView: View {
    let carta: Carta

    var body: some View {
        let visibile = carta.scoperta || carta.trovata
        RoundedRectangle(cornerRadius: 20)
            .fill(visibile ? Color.white : Color.blue.opacity(0.6))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if visibile {
                    Image(systemName: carta.simbolo)
                        .font(.system(size: 60))
                        .foregroundStyle(carta.trovata ? .green : .orange)
                }
            }
            .shadow(radius: 3)
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { GiocoMemoriaView(coppie: 4) }
}
