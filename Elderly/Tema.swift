import SwiftUI

/// Colori che cambiano da soli tra modalità chiara e scura.
enum Tema {
    private static func dinamico(chiaro: UIColor, scuro: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? scuro : chiaro })
    }

    /// Celeste dei mockup (#5EB6FF). Testo blu notte: contrasto 6,4:1 (soglia AA 4,5:1). Mai testo bianco direttamente sul celeste.
    static let celeste = Color(red: 0.37, green: 0.71, blue: 1.0)

    /// Blu notte sul cielo chiaro, bianco sul cielo scuro: contrasto oltre 7:1.
    static let testo = dinamico(chiaro: UIColor(red: 0.07, green: 0.17, blue: 0.30, alpha: 1), scuro: .white)
    static let testoSecondario = dinamico(chiaro: UIColor(red: 0.08, green: 0.20, blue: 0.34, alpha: 1),
                                          scuro: UIColor(white: 1, alpha: 0.85))
    static let sole = Color(red: 1.0, green: 0.80, blue: 0.20)
    static let azzurroProfondo = Color(red: 0.04, green: 0.27, blue: 0.62)
}

/// Cielo con nuvole morbide. Si muove pianissimo; fermo se l'utente riduce i movimenti,
/// piatto se chiede più contrasto o meno trasparenza.
struct SfondoCielo: View {
    @Environment(\.colorScheme) private var schema
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @Environment(\.accessibilityReduceTransparency) private var pocaTrasparenza
    @Environment(\.colorSchemeContrast) private var contrasto

    var body: some View {
        Group {
            if pocaTrasparenza || contrasto == .increased {
                (schema == .dark ? Color(red: 0.05, green: 0.12, blue: 0.26) : Tema.celeste)
            } else {
                TimelineView(.animation(minimumInterval: 1 / 15, paused: pocoMovimento)) { contesto in
                    MeshGradient(width: 3, height: 3,
                                 points: punti(contesto.date.timeIntervalSinceReferenceDate),
                                 colors: colori)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var colori: [Color] {
        if schema == .dark {
            let notte = Color(red: 0.05, green: 0.12, blue: 0.28), alba = Color(red: 0.16, green: 0.30, blue: 0.55)
            return [notte, alba, notte, alba, notte, alba, notte, alba, notte]
        }
        // Varia di pochissimo attorno al celeste dei mockup: abbastanza per sembrare cielo, non per perdere contrasto.
        let base = Tema.celeste, chiaro = Color(red: 0.50, green: 0.78, blue: 1.0)
        return [base, chiaro, base,
                chiaro, base, chiaro,
                base, chiaro, base]
    }

    private func punti(_ t: TimeInterval) -> [SIMD2<Float>] {
        let k = pocoMovimento ? 0 : Float(t)
        func onda(_ fase: Float, _ ampiezza: Float) -> Float { sin(k * 0.25 + fase) * ampiezza }
        return [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5 + onda(0, 0.06)], [0.5 + onda(1, 0.12), 0.5 + onda(2, 0.12)], [1, 0.5 + onda(3, 0.06)],
            [0, 1], [0.5 + onda(4, 0.1), 1], [1, 1],
        ]
    }
}


/// Scala dei testi. Tutta l'app usa questi: per cambiare la grandezza si cambiano solo questi numeri.
enum DimensioneTesto {
    static let enorme: CGFloat = 96
    static let titolo: CGFloat = 72
    static let grande: CGFloat = 56
    static let medio: CGFloat = 44
    static let normale: CGFloat = 36
}

private struct StileTesto: ViewModifier {
    @ScaledMetric private var dimensione: CGFloat
    let peso: Font.Weight

    init(_ base: CGFloat, _ peso: Font.Weight) {
        _dimensione = ScaledMetric(wrappedValue: base, relativeTo: .title)
        self.peso = peso
    }

    func body(content: Content) -> some View {
        content.font(.system(size: dimensione, weight: peso, design: .rounded))
    }
}

extension View {
    /// Testo in SF Rounded che segue la grandezza scelta dall'utente nelle impostazioni di iOS.
    func testo(_ dimensione: CGFloat, _ peso: Font.Weight = .regular) -> some View {
        modifier(StileTesto(dimensione, peso))
    }
}
