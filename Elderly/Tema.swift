import SwiftUI

/// LA PALETTE DELL'APP. Tutti i colori vengono da qui: si cambia un valore e cambia ovunque.
///
/// Famiglia degli azzurri, dal più chiaro al più scuro:
///   cielo (sfondo)  ·  azzurro (pulsanti vivaci)  ·  azzurro scuro (azione principale)  ·  notte (rari accenti)
/// Due colori "di significato", usati solo quando serve dire sì/no o giusto/sbagliato:
///   verde (sì, giusto)  ·  rosso (no)
/// Il secondo giocatore è invece caldo (pesca e arancio): così il cambio di turno si vede subito, anche da lontano. Il testo è marrone scuro quasi nero.
/// Tutti i colori con il testo bianco sopra hanno un contrasto di almeno 5:1.
nonisolated enum Tema {   // solo costanti: si possono leggere da ovunque
    // — Sfondi
    static let celeste = Color(hex: 0xA9D8FF)         // cielo: sfondo di tutte le schermate (con il testo scuro: 11:1)
    static let celesteChiaro = Color(hex: 0xC4E6FF)   // cielo più chiaro: sfumature e riquadri
    static let pesca = Color(hex: 0xFFCF9E)              // sfondo del secondo giocatore: pesca, l'opposto del celeste (testo scuro sopra: 12:1)
    static let pescaChiaro = Color(hex: 0xFFE2C2)
    static let carta = Color.white                    // schede e campi

    // — Azzurri (testo bianco sopra)
    static let azzurro = Color(hex: 0x1C6FBF)         // pulsanti vivaci, per esempio "Ascolta" (5,2:1)
    static let blu = Color(hex: 0x0A4595)             // azione principale e primo giocatore (9,1:1)
    static let notte = Color(hex: 0x072B5B)           // accenti rari e molto scuri (13,9:1)
    static let arancio = Color(hex: 0xB3500C)         // secondo giocatore: arancio scuro (testo bianco sopra: 5,3:1)

    // — Colori di significato
    static let verde = Color(hex: 0x0B7A54)           // sì, giusto (5,3:1)
    static let rosso = Color(hex: 0xB3261E)           // no (6,5:1)

    // — Testo (marrone scuro quasi nero: 11:1 sul cielo, 16,7:1 sul bianco)
    static let testo = Color(hex: 0x2A1A12)
    static let testoSecondario = Color(hex: 0x4B3326)

    /// Il colore di ogni giocatore: il primo azzurro scuro, il secondo arancio scuro.
    static func coloreGiocatore(_ posizione: Int) -> Color { posizione == 0 ? blu : arancio }

    static let raggio: CGFloat = 40   // angoli di schede e pulsanti (morbidi, come nelle app Apple)
}

extension Color {
    /// Un colore da un numero esadecimale, per esempio `Color(hex: 0xA9D8FF)`.
    nonisolated init(hex: UInt32) {
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

    private var base: Color { turno == 1 ? Tema.pesca : Tema.celeste }
    private var chiaro: Color { turno == 1 ? Tema.pescaChiaro : Tema.celesteChiaro }

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
        .onDisappear { Sintetizzatore.condiviso.fermaConDissolvenza() }   // cambio scena: i suoni sfumano in mezzo secondo
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

    /// Se la schermata non ci sta (iPad più piccoli, testo grande) si può scorrere.
    /// Se ci sta resta identica, ferma e con gli elementi che riempiono lo spazio.
    func scorriSeServe() -> some View { modifier(ScorriSeServe()) }

    /// Pulsante in vetro colorato, con il testo bianco o scuro a seconda del colore.
    func vetro(_ colore: Color, in forma: some Shape = Capsule()) -> some View {
        glassEffect(.regular.tint(colore), in: forma)
            .contentShape(forma)   // senza questo il tocco funziona solo sopra le lettere
    }
}

private struct ScorriSeServe: ViewModifier {
    @State private var altroSotto = false
    @State private var scorre = false       // il contenuto è più alto dello schermo
    @State private var posizione = ScrollPosition(edge: .top)

    func body(content: Content) -> some View {
        GeometryReader { schermo in
            // alto almeno quanto lo schermo: se ci sta lo riempie come prima, se è più lungo si scorre.
            // largo quanto lo schermo, così la barra di scorrimento sta sul bordo destro e non accanto al contenuto
            ScrollView {
                content.frame(width: schermo.size.width, height: nil)
                    .frame(minHeight: schermo.size.height)
            }
            .scrollPosition($posizione)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.visible)
            .scrollIndicatorsFlash(onAppear: true)
            // se si scorre, in fondo c'è spazio libero: l'ultimo elemento non resta sotto il pulsante "Scorri in giù"
            .contentMargins(.bottom, scorre ? 40 : 0, for: .scrollContent)
            .onScrollGeometryChange(for: Bool.self) { g in
                g.contentSize.height > g.containerSize.height + 1
            } action: { _, nuovo in
                scorre = nuovo
            }
            .onScrollGeometryChange(for: Bool.self) { g in
                g.visibleRect.maxY < g.contentSize.height - 24   // c'è ancora contenuto sotto il bordo dello schermo
            } action: { _, nuovo in
                withAnimation(.easeInOut(duration: 0.3)) { altroSotto = nuovo }
            }
            .clipped()   // il contenuto non passa sotto la barra con il titolo
            // la barra di scorrimento è sottile e sparisce: finché c'è altro sotto lo diciamo chiaramente
            // finché c'è altro sotto: il bordo in basso sfuma (si vede che le cose continuano) e nell'angolo
            // c'è una freccia tonda che si muove piano. Non copre più i pulsanti al centro dello schermo.
            .overlay(alignment: .bottom) {
                if altroSotto {
                    LinearGradient(colors: [Tema.celeste.opacity(0), Tema.celeste.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 90)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if altroSotto {
                    Button { withAnimation(.easeInOut(duration: 0.5)) { posizione.scrollTo(edge: .bottom) } } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce.down, options: .repeat(.periodic(delay: 1.5)))
                            .frame(width: 76, height: 76)
                            .vetro(Tema.blu, in: Circle())
                    }
                    .buttonStyle(StilePremuto())
                    .accessibilityLabel("Scorri in giù, c'è altro")
                    .padding(.trailing, 28).padding(.bottom, 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

extension View {
    /// Entra da sotto, crescendo un poco, con un piccolo rimbalzo: uno dopo l'altro secondo `posizione`.
    /// Con "Riduci movimento" attivo compare solo a dissolvenza.
    func entrataAScaletta(_ posizione: Int) -> some View { modifier(EntrataAScaletta(posizione: posizione)) }
}

private struct EntrataAScaletta: ViewModifier {
    let posizione: Int
    @State private var dentro = false
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento

    func body(content: Content) -> some View {
        content
            .opacity(dentro ? 1 : 0)
            .scaleEffect(dentro || pocoMovimento ? 1 : 0.9)
            .offset(y: dentro || pocoMovimento ? 0 : 40)
            .onAppear {
                withAnimation(.spring(duration: 0.55, bounce: 0.35).delay(0.08 * Double(posizione))) { dentro = true }
            }
    }
}

extension View {
    /// Con due persone in partita la scheda prende il colore di chi gioca: un bordo spesso e una velatura leggera.
    /// Da soli resta com'è. Si mette su schede, foto e risposte, così tutto lo schermo dice di chi è il turno.
    func coloreDelTurno(raggio: CGFloat = Tema.raggio, attivo: Bool = true) -> some View {
        modifier(ColoreDelTurno(raggio: raggio, attivo: attivo))
    }
}

private struct ColoreDelTurno: ViewModifier {
    let raggio: CGFloat
    let attivo: Bool
    @Environment(\.turnoGioco) private var turno

    func body(content: Content) -> some View {
        let colore = turno.map(Tema.coloreGiocatore)
        let forma = RoundedRectangle(cornerRadius: raggio, style: .continuous)
        content
            .overlay { if attivo, let colore { forma.fill(colore.opacity(0.08)).allowsHitTesting(false) } }
            .overlay { if attivo, let colore { forma.strokeBorder(colore, lineWidth: 6).allowsHitTesting(false) } }
            .animation(.easeInOut(duration: 0.5), value: turno)
    }
}
