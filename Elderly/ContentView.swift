import SwiftUI

/// La prima schermata: il logo, il titolo e tre pulsanti enormi. All'apertura tutto entra in sequenza.
struct ContentView: View {
    @State private var entrato = false

    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()
                DecorazioniHome()

                // la home non scorre mai: sugli schermi bassi (iPad mini) tutto si stringe in proporzione
                GeometryReader { schermo in
                    let s = min(1, schermo.size.height / 860)
                    VStack(spacing: 56 * s) {
                        Titolo(entrato: entrato, scala: s)

                        VStack(spacing: 20 * s) {
                            NavigationLink(destination: ChiGiocaView()) {
                                PulsantePrincipale(titolo: "Gioca", altezza: 130 * s)
                                    .overlay { Riflesso(attivo: entrato, ritardo: 1.9) }
                                    .modifier(Respiro(attivo: entrato))
                            }
                            .appari(entrato, ritardo: 1.0)
                            NavigationLink(destination: UtentiView()) {
                                PulsanteSecondario(titolo: "Utenti", altezza: 110 * s)
                            }
                            .appari(entrato, ritardo: 1.2)
                            NavigationLink(destination: OpzioniView()) {
                                PulsanteSecondario(titolo: "Opzioni", altezza: 110 * s)
                            }
                            .appari(entrato, ritardo: 1.4)
                        }
                        .buttonStyle(StilePremuto())
                        .frame(maxWidth: 640)
                    }
                    .padding(40 * s)
                    .frame(width: schermo.size.width, height: schermo.size.height)
                }
            }
        }
        .task {
            // si aspetta che la schermata sia disposta: se no le cose "volano" dalla posizione iniziale
            try? await Task.sleep(for: .seconds(0.3))
            entrato = true   // ogni elemento ha la sua animazione con il suo ritardo
        }
    }
}

extension View {
    /// Sale dal basso con un rimbalzo e un'ombra che si allarga, come se si appoggiasse sullo schermo.
    /// Uno dopo l'altro secondo il ritardo. Con "Riduci movimento" compare solo a dissolvenza.
    fileprivate func appari(_ entrato: Bool, ritardo: Double) -> some View {
        modifier(Appari(entrato: entrato, ritardo: ritardo))
    }
}

private struct Appari: ViewModifier {
    let entrato: Bool
    let ritardo: Double
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento

    func body(content: Content) -> some View {
        content
            .shadow(color: Tema.notte.opacity(entrato ? 0.22 : 0), radius: entrato ? 18 : 0, y: entrato ? 12 : 0)
            .scaleEffect(entrato || pocoMovimento ? 1 : 0.85)
            .offset(y: entrato || pocoMovimento ? 0 : 70)
            .opacity(entrato ? 1 : 0)
            .animation(pocoMovimento ? .easeIn(duration: 0.6).delay(ritardo) : .spring(duration: 0.7, bounce: 0.4).delay(ritardo), value: entrato)
    }
}

/// Il pulsante cresce e torna piano ogni pochi secondi: invita a toccarlo, senza fretta.
private struct Respiro: ViewModifier {
    let attivo: Bool
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento

    func body(content: Content) -> some View {
        content
            .task(id: attivo) {
                // dopo l'entrata, un "respiro" ogni 4 secondi finché si resta nella home
                guard attivo, !pocoMovimento else { return }
                try? await Task.sleep(for: .seconds(2.8))
                while !Task.isCancelled {
                    respiri += 1
                    try? await Task.sleep(for: .seconds(4))
                }
            }
            .phaseAnimator([false, true, false], trigger: respiri) { vista, grande in
                vista.scaleEffect(grande && !pocoMovimento ? 1.04 : 1)
            } animation: { _ in .easeInOut(duration: 1.1) }
    }

    @State private var respiri = 0
}

/// Un lampo di luce che attraversa il pulsante una volta sola, da sinistra a destra.
private struct Riflesso: View {
    let attivo: Bool
    let ritardo: Double
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento

    var body: some View {
        GeometryReader { spazio in
            LinearGradient(colors: [.white.opacity(0), .white.opacity(0.55), .white.opacity(0)], startPoint: .leading, endPoint: .trailing)
                .frame(width: spazio.size.width * 0.3)
                .rotationEffect(.degrees(20))
                .offset(x: attivo ? spazio.size.width * 1.2 : -spazio.size.width * 0.5)
                .animation(pocoMovimento ? nil : .easeInOut(duration: 0.9).delay(ritardo), value: attivo)
        }
        .clipShape(Capsule())
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .opacity(pocoMovimento ? 0 : 1)
    }
}

/// Il nome dell'app, grande, con sotto una striscia con una piccola "v" che si disegna da sinistra a destra.
/// È largo quanto i pulsanti. (Il logo con i due nonni resta l'icona dell'app.)
private struct Titolo: View {
    let entrato: Bool
    var scala: CGFloat = 1

    var body: some View {
        VStack(spacing: 10) {
            // il nome in San Francisco bold; sotto, la linea con la "v" e i ghirigori ai lati
            // le lettere cadono una dopo l'altra, con un rimbalzo; poi intorno al nome scoppiano delle stelline
            LettereCadenti(testo: "Elderly", corpo: 150 * scala, entrato: entrato)
                .overlay { Scintille(attiva: entrato, ritardo: 0.9) }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Elderly")
                // mentre le lettere atterrano, l'ombra sotto si stringe e si fa netta
                .shadow(color: Tema.testo.opacity(entrato ? 0.22 : 0), radius: entrato ? 14 : 40, y: entrato ? 10 : 40)
                .animation(.easeOut(duration: 1.0), value: entrato)
                .accessibilityAddTraits(.isHeader)

            Ghirigoro()
                .trim(from: 0, to: entrato ? 1 : 0)
                .stroke(Tema.blu, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .frame(height: 80 * scala)
                .animation(.easeInOut(duration: 0.9).delay(0.4), value: entrato)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: 640)   // la stessa larghezza dei pulsanti
    }
}

/// Il nome scritto lettera per lettera: ogni lettera cade dall'alto ruotando un poco e si posa con un rimbalzo.
private struct LettereCadenti: View {
    let testo: String
    let corpo: CGFloat
    let entrato: Bool
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento

    var body: some View {
        HStack(spacing: -corpo * 0.02) {
            ForEach(Array(testo.enumerated()), id: \.offset) { n, lettera in
                Text(String(lettera))
                    .font(.system(size: corpo, weight: .bold))   // grassetto sempre, su ogni iPad
                    .foregroundStyle(Tema.testo)
                    .offset(y: entrato || pocoMovimento ? 0 : -corpo * 0.9)
                    .rotationEffect(.degrees(entrato || pocoMovimento ? 0 : (n.isMultiple(of: 2) ? -25 : 25)))
                    .opacity(entrato ? 1 : 0)
                    .animation(pocoMovimento ? .easeIn(duration: 0.6) : .spring(duration: 0.6, bounce: 0.5).delay(0.07 * Double(n)), value: entrato)
            }
        }
        .lineLimit(1)
        .fixedSize()
    }
}

/// Stelline che partono dal centro del nome e si allontanano svanendo, una volta sola: un piccolo "fuoco d'artificio".
private struct Scintille: View {
    let attiva: Bool
    let ritardo: Double
    @State private var via = false
    @State private var partite = false
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    private let colori: [Color] = [Forma.cerchio.colore, Forma.quadrato.colore, Forma.triangolo.colore, Forma.stella.colore, Forma.cuore.colore]

    var body: some View {
        GeometryReader { spazio in
            ZStack {
                ForEach(0..<14, id: \.self) { n in
                    let angolo = Double(n) / 14 * 2 * .pi
                    let distanza = max(spazio.size.width, spazio.size.height) * (n.isMultiple(of: 2) ? 0.62 : 0.48)
                    Forma.stella.sagoma
                        .fill(colori[n % colori.count])
                        .frame(width: n.isMultiple(of: 3) ? 30 : 20, height: n.isMultiple(of: 3) ? 30 : 20)
                        .rotationEffect(.degrees(via ? 220 : 0))
                        .scaleEffect(via ? 0.3 : 1.1)
                        .offset(x: via ? cos(angolo) * distanza : 0, y: via ? sin(angolo) * distanza * 0.55 : 0)
                        .opacity(via ? 0 : 1)
                }
            }
            .frame(width: spazio.size.width, height: spazio.size.height)
            .opacity(partite && !pocoMovimento ? 1 : 0)   // si vedono solo mentre volano via, non prima
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task(id: attiva) {
            guard attiva, !pocoMovimento else { return }
            try? await Task.sleep(for: .seconds(ritardo))
            partite = true
            withAnimation(.easeOut(duration: 1.3)) { via = true }
        }
    }
}

/// La linea sotto il nome: dritta, con una piccola "v" morbida al centro e un ghirigoro (un ricciolo) a ciascuna estremità: @-----v-----@
private struct Ghirigoro: Shape {
    func path(in rect: CGRect) -> Path {
        let y = rect.midY
        let centro = rect.midX
        let apertura = rect.width * 0.045
        let ricciolo: CGFloat = rect.height * 0.5            // grandezza dei ghirigori
        let margine = ricciolo * 2.2                          // spazio per il ricciolo ai lati
        var p = Path()

        // lato sinistro: parte dal ricciolo e va verso il centro
        p.move(to: CGPoint(x: rect.minX + margine, y: y))
        riccio(&p, da: CGPoint(x: rect.minX + margine, y: y), verso: -1, misura: ricciolo)

        p.move(to: CGPoint(x: rect.minX + margine, y: y))
        p.addLine(to: CGPoint(x: centro - apertura * 1.6, y: y))
        // la "v"
        p.addQuadCurve(to: CGPoint(x: centro, y: y + rect.height * 0.42), control: CGPoint(x: centro - apertura * 0.5, y: y))
        p.addQuadCurve(to: CGPoint(x: centro + apertura * 1.6, y: y), control: CGPoint(x: centro + apertura * 0.5, y: y))
        p.addLine(to: CGPoint(x: rect.maxX - margine, y: y))

        // lato destro
        riccio(&p, da: CGPoint(x: rect.maxX - margine, y: y), verso: 1, misura: ricciolo)
        return p
    }

    /// Un ricciolo: la linea sale di lato e si arrotola su se stessa, come una spirale che si stringe.
    private func riccio(_ p: inout Path, da inizio: CGPoint, verso d: CGFloat, misura m: CGFloat) {
        let raggio = m * 1.1
        let centro = CGPoint(x: inizio.x + d * raggio, y: inizio.y - raggio)   // il punto di partenza è in fondo al cerchio
        p.move(to: inizio)
        let passi = 80
        for k in 1...passi {
            let t = CGFloat(k) / CGFloat(passi)
            let angolo = .pi / 2 - d * 2.5 * .pi * t            // un giro e un quarto
            let r = raggio * (1 - 0.78 * t)                     // il raggio si restringe
            p.addLine(to: CGPoint(x: centro.x + d * r * cos(angolo) * d, y: centro.y + r * sin(angolo)))
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
