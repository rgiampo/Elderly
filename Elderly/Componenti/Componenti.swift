import SwiftUI

/// Scheda bianca grande con testo scuro: sempre leggibile sul celeste.
extension View {
    func scheda(raggio: CGFloat = 32) -> some View {
        background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: raggio))
            .shadow(color: Tema.testo.opacity(0.18), radius: 12, y: 6)
    }
}

/// Il tocco "affonda" leggermente, così si capisce che il bottone ha risposto.
struct StilePremuto: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

/// Testo del menu: italiano grande, inglese piccolo sotto.
struct EtichettaMenu: View {
    let italiano: String
    let inglese: String
    var colore: Color = Tema.testo

    var body: some View {
        VStack(spacing: 2) {
            Text(italiano).font(.system(.largeTitle, design: .rounded, weight: .heavy))
            Text(inglese).font(.system(.title3, design: .rounded, weight: .medium)).opacity(0.85)
        }
        .foregroundStyle(colore)
        .frame(maxWidth: .infinity, minHeight: 120)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(italiano)
    }
}

/// Logo provvisorio: le cinque forme del gioco.
struct Logo: View {
    var body: some View {
        HStack(spacing: -10) {
            ForEach(Forma.allCases) { forma in
                forma.sagoma.fill(forma.colore).frame(width: 54, height: 54)
            }
        }
        .padding(24)
        .glassEffect(.regular, in: .rect(cornerRadius: 36))
        .accessibilityHidden(true)
    }
}
