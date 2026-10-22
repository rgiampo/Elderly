import SwiftUI

struct GiocoView: View {
    @State private var partita: PartitaModello

    init(giocatori: Int, difficolta: Difficolta) {
        _partita = State(initialValue: PartitaModello(giocatori: giocatori, difficolta: difficolta))
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.85, green: 0.93, blue: 1), .white],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                if partita.giocatori > 1 {
                    Text("Tocca a: Giocatore \(partita.giocatoreCorrente + 1)")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Text(partita.messaggio)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .contentTransition(.opacity)

                HStack(spacing: 36) {
                    ForEach(partita.forme) { forma in
                        FormaBottone(forma: forma, accesa: partita.formaAccesa == forma) {
                            partita.tocca(forma)
                        }
                    }
                }
                .padding(.horizontal, 40)

                Text("Sequenza più lunga insieme: \(partita.record)")
                    .font(.system(size: 28, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            if partita.fase == .festa { Coriandoli().allowsHitTesting(false) }
        }
        .animation(.easeInOut, value: partita.messaggio)
        .onAppear { partita.inizia() }
        .onDisappear { partita.ferma() }
    }
}

struct FormaBottone: View {
    let forma: Forma
    let accesa: Bool
    let azione: () -> Void

    var body: some View {
        Button(action: azione) {
            forma.sagoma
                .fill(forma.colore.gradient)
                .overlay(forma.sagoma.stroke(.white.opacity(0.6), lineWidth: 8))
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 240, maxHeight: 240)
                .shadow(color: forma.colore.opacity(accesa ? 0.9 : 0.25), radius: accesa ? 40 : 8, y: 6)
                .scaleEffect(accesa ? 1.18 : 1)
                .brightness(accesa ? 0.25 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(describing: forma))
    }
}

/// Piccola festa: pallini colorati che cadono una volta sola.
struct Coriandoli: View {
    @State private var cadi = false
    private let pezzi = (0..<40).map { _ in
        (x: CGFloat.random(in: 0...1), ritardo: Double.random(in: 0...0.6),
         dimensione: CGFloat.random(in: 14...30), forma: Forma.allCases.randomElement()!)
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(pezzi.indices, id: \.self) { i in
                pezzi[i].forma.sagoma
                    .fill(pezzi[i].forma.colore)
                    .frame(width: pezzi[i].dimensione, height: pezzi[i].dimensione)
                    .position(x: pezzi[i].x * geo.size.width, y: cadi ? geo.size.height + 40 : -40)
                    .animation(.easeIn(duration: 2).delay(pezzi[i].ritardo), value: cadi)
            }
        }
        .onAppear { cadi = true }
    }
}

#Preview(traits: .landscapeLeft) {
    GiocoView(giocatori: 3, difficolta: .medio)
}
