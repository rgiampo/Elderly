import SwiftUI

/// Colori dell'app. Sempre in modalità chiara: i contrasti sono stati misurati per questa.
enum Tema {
    /// Celeste di sfondo (#A9D8FF): chiaro e riposante per gli occhi.
    /// Con il testo blu notte il contrasto è 10:1 (la soglia AAA è 7:1). Mai testo bianco direttamente sul celeste.
    static let celeste = Color(red: 0.66, green: 0.85, blue: 1.0)
    static let celesteChiaro = Color(red: 0.76, green: 0.90, blue: 1.0)

    /// Marrone scuro quasi nero (#2A1A12): contrasto 12:1 sul celeste e 16:1 sul bianco.
    static let testo = Color(red: 0.165, green: 0.10, blue: 0.07)
    static let testoSecondario = Color(red: 0.30, green: 0.20, blue: 0.14)

    static let carta = Color.white
    static let blu = Color(red: 0.04, green: 0.27, blue: 0.62)         // testo bianco sopra: 8,9:1
    static let arancione = Color(red: 0.72, green: 0.30, blue: 0.04)   // testo bianco sopra: 5,1:1
    static let verde = Color(red: 0.05, green: 0.45, blue: 0.22)       // testo bianco sopra: 6,6:1
    static let rosso = Color(red: 0.75, green: 0.12, blue: 0.12)       // testo bianco sopra: 6,5:1
    static let giallo = Color(red: 1.0, green: 0.80, blue: 0.20)       // testo scuro sopra

    /// Il colore di ogni giocatore: il primo blu, il secondo arancione.
    static func coloreGiocatore(_ posizione: Int) -> Color { posizione == 0 ? blu : arancione }

    static let raggio: CGFloat = 40   // angoli di schede e pulsanti (morbidi, come nelle app Apple)
}

/// Sfondo celeste, quasi piatto: una luce morbida che si sposta lentamente.
/// Fermo se l'utente riduce i movimenti, piatto se chiede meno trasparenza o più contrasto.
struct SfondoCielo: View {
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @Environment(\.accessibilityReduceTransparency) private var pocaTrasparenza
    @Environment(\.colorSchemeContrast) private var contrasto

    var body: some View {
        Group {
            if pocaTrasparenza || contrasto == .increased {
                Tema.celeste
            } else {
                TimelineView(.animation(minimumInterval: 1 / 15, paused: pocoMovimento)) { contesto in
                    MeshGradient(width: 3, height: 3,
                                 points: punti(contesto.date.timeIntervalSinceReferenceDate),
                                 colors: [Tema.celeste, Tema.celesteChiaro, Tema.celeste,
                                          Tema.celesteChiaro, Tema.celeste, Tema.celesteChiaro,
                                          Tema.celeste, Tema.celesteChiaro, Tema.celeste])
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func punti(_ t: TimeInterval) -> [SIMD2<Float>] {
        let k = pocoMovimento ? 0 : Float(t)
        func onda(_ fase: Float, _ ampiezza: Float) -> Float { sin(k * 0.2 + fase) * ampiezza }
        return [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5 + onda(0, 0.05)], [0.5 + onda(1, 0.1), 0.5 + onda(2, 0.1)], [1, 0.5 + onda(3, 0.05)],
            [0, 1], [0.5 + onda(4, 0.08), 1], [1, 1],
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

/// Tutto il testo dell'app è San Francisco (il font di sistema) in grassetto: si legge meglio da lontano.
private struct StileTesto: ViewModifier {
    @ScaledMetric private var dimensione: CGFloat

    init(_ base: CGFloat) {
        _dimensione = ScaledMetric(wrappedValue: base, relativeTo: .title)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: dimensione, weight: .bold))
    }
}

extension View {
    /// Testo che segue la grandezza scelta dall'utente nelle impostazioni di iOS.
    func testo(_ dimensione: CGFloat) -> some View {
        modifier(StileTesto(dimensione))
    }

    /// Scheda in vetro (Liquid Glass) schiarito di bianco: i testi scuri restano leggibilissimi sul celeste.
    func scheda(raggio: CGFloat = Tema.raggio) -> some View {
        glassEffect(.regular.tint(.white.opacity(0.78)), in: RoundedRectangle(cornerRadius: raggio, style: .continuous))
    }

    /// Pulsante in vetro colorato, con il testo bianco o scuro a seconda del colore.
    func vetro(_ colore: Color, in forma: some Shape = Capsule()) -> some View {
        glassEffect(.regular.tint(colore), in: forma)
    }
}
