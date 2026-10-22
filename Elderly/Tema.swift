import SwiftUI

/// Colori che cambiano da soli tra modalità chiara e scura.
enum Tema {
    private static func dinamico(chiaro: UIColor, scuro: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? scuro : chiaro })
    }

    /// Blu notte sul cielo chiaro, bianco sul cielo scuro: contrasto oltre 7:1.
    static let testo = dinamico(chiaro: UIColor(red: 0.07, green: 0.17, blue: 0.30, alpha: 1), scuro: .white)
    static let testoSecondario = dinamico(chiaro: UIColor(red: 0.16, green: 0.30, blue: 0.46, alpha: 1),
                                          scuro: UIColor(white: 1, alpha: 0.85))
    static let sole = Color(red: 1.0, green: 0.80, blue: 0.20)
    static let azzurroProfondo = Color(red: 0.07, green: 0.36, blue: 0.75)
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
                (schema == .dark ? Color(red: 0.05, green: 0.12, blue: 0.26) : Color(red: 0.80, green: 0.92, blue: 1.0))
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
        let cielo = Color(red: 0.55, green: 0.80, blue: 0.98), nuvola = Color(red: 0.97, green: 0.99, blue: 1.0)
        let chiaro = Color(red: 0.78, green: 0.91, blue: 0.99)
        return [cielo, chiaro, cielo,
                nuvola, chiaro, nuvola,
                chiaro, nuvola, chiaro]
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
