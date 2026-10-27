import SwiftUI

/// LA PALETTE DELL'APP. Tutti i colori vengono da qui: si cambia un valore e cambia ovunque.
///
/// Famiglia degli azzurri, dal più chiaro al più scuro:
///   cielo (sfondo)  ·  azzurro (pulsanti vivaci)  ·  azzurro scuro (azione principale)  ·  notte (rari accenti)
/// Due colori "di significato", usati solo quando serve dire sì/no o giusto/sbagliato:
///   verde (sì, giusto)  ·  rosso (no)
/// Più il petrolio, un azzurro-verde scuro, per il secondo giocatore. Il testo è marrone scuro quasi nero.
/// Tutti i colori con il testo bianco sopra hanno un contrasto di almeno 5:1.
enum Tema {
    // — Sfondi
    static let celeste = Color(hex: 0xA9D8FF)         // cielo: sfondo di tutte le schermate (con il testo scuro: 11:1)
    static let celesteChiaro = Color(hex: 0xC4E6FF)   // cielo più chiaro: sfumature e riquadri
    static let celesteMenta = Color(hex: 0xA6E3D4)       // sfondo del secondo giocatore: verde acqua chiaro (testo scuro sopra: 12:1)
    static let celesteMentaChiaro = Color(hex: 0xC2EFE3)
    static let carta = Color.white                    // schede e campi

    // — Azzurri (testo bianco sopra)
    static let azzurro = Color(hex: 0x1C6FBF)         // pulsanti vivaci, per esempio "Ascolta" (5,2:1)
    static let blu = Color(hex: 0x0A4595)             // azione principale e primo giocatore (9,1:1)
    static let notte = Color(hex: 0x072B5B)           // accenti rari e molto scuri (13,9:1)
    static let petrolio = Color(hex: 0x0B6E86)        // secondo giocatore: azzurro-verde scuro (5,9:1)

    // — Colori di significato
    static let verde = Color(hex: 0x0B7A54)           // sì, giusto (5,3:1)
    static let rosso = Color(hex: 0xB3261E)           // no (6,5:1)

    // — Testo (marrone scuro quasi nero: 11:1 sul cielo, 16,7:1 sul bianco)
    static let testo = Color(hex: 0x2A1A12)
    static let testoSecondario = Color(hex: 0x4B3326)

    /// Il colore di ogni giocatore: il primo azzurro scuro, il secondo petrolio.
    static func coloreGiocatore(_ posizione: Int) -> Color { posizione == 0 ? blu : petrolio }

    static let raggio: CGFloat = 40   // angoli di schede e pulsanti (morbidi, come nelle app Apple)
}

extension Color {
    /// Un colore da un numero esadecimale, per esempio `Color(hex: 0xA9D8FF)`.
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// Di chi è il turno: lo scrivono i giochi, lo legge lo sfondo. Con una persona sola resta `nil` e lo sfondo non cambia.
private struct ChiaveTurno: EnvironmentKey { static let defaultValue: Int? = nil }
extension EnvironmentValues {
    var turnoGioco: Int? {
        get { self[ChiaveTurno.self] }
        set { self[ChiaveTurno.self] = newValue }
    }
}

extension View {
    /// Con due giocatori lo sfondo cambia colore a ogni turno: azzurro per il primo, verde acqua per il secondo.
    func coloreSfondoDelTurno(_ giocatori: [Partecipante], turno: Int) -> some View {
        environment(\.turnoGioco, giocatori.count > 1 ? turno : nil)
    }
}

/// Sfondo celeste, quasi piatto: una luce morbida che si sposta lentamente.
/// Fermo se l'utente riduce i movimenti, piatto se chiede meno trasparenza o più contrasto.
struct SfondoCielo: View {
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @Environment(\.accessibilityReduceTransparency) private var pocaTrasparenza
    @Environment(\.colorSchemeContrast) private var contrasto
    @Environment(\.turnoGioco) private var turno

    private var base: Color { turno == 1 ? Tema.celesteMenta : Tema.celeste }
    private var chiaro: Color { turno == 1 ? Tema.celesteMentaChiaro : Tema.celesteChiaro }

    var body: some View {
        Group {
            if pocaTrasparenza || contrasto == .increased {
                base
            } else {
                TimelineView(.animation(minimumInterval: 1 / 15, paused: pocoMovimento)) { contesto in
                    MeshGradient(width: 3, height: 3,
                                 points: punti(contesto.date.timeIntervalSinceReferenceDate),
                                 colors: [base, chiaro, base, chiaro, base, chiaro, base, chiaro, base])
                }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.7), value: turno)   // il cambio di colore è una dissolvenza lenta
        .accessibilityHidden(true)
        .onDisappear { Sintetizzatore.condiviso.fermaConDissolvenza() }   // cambio scena: i suoni sfumano in 0,2 s
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
    @AppStorage(Grandezza.chiaveTesto) private var scelta = Grandezza.media.rawValue

    init(_ base: CGFloat) {
        _dimensione = ScaledMetric(wrappedValue: base, relativeTo: .title)
    }

    func body(content: Content) -> some View {
        let fattore = (Grandezza(rawValue: scelta) ?? .media).fattoreTesto
        content.font(.system(size: dimensione * fattore, weight: .bold))
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
            .contentShape(RoundedRectangle(cornerRadius: raggio, style: .continuous))
    }

    /// Pulsante in vetro colorato, con il testo bianco o scuro a seconda del colore.
    func vetro(_ colore: Color, in forma: some Shape = Capsule()) -> some View {
        glassEffect(.regular.tint(colore), in: forma)
            .contentShape(forma)   // senza questo il tocco funziona solo sopra le lettere
    }
}
