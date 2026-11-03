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
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento

    var body: some View {
        VStack(spacing: 10) {
            // il nome in San Francisco bold; sotto, la linea con la "v" e i ghirigori ai lati
            Text("Elderly")
                .font(.system(size: 150 * scala, weight: .bold))   // grassetto sempre, su ogni iPad
                .tracking(-3)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.4)
                // entra dall'alto, sfocato e un po' più grande, e si "posa": l'ombra sotto cresce mentre arriva
                .shadow(color: Tema.testo.opacity(entrato ? 0.22 : 0), radius: entrato ? 14 : 40, y: entrato ? 10 : 40)
                .blur(radius: entrato || pocoMovimento ? 0 : 14)
                .scaleEffect(entrato || pocoMovimento ? 1 : 1.25)
                .offset(y: entrato || pocoMovimento ? 0 : -40)
                .opacity(entrato ? 1 : 0)
                .animation(pocoMovimento ? .easeIn(duration: 0.6) : .spring(duration: 0.9, bounce: 0.3), value: entrato)
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

/// La "E" del nome: blu, con tre strisce per lato che seguono le sue tre barre (come linee di velocità).
private struct EConStrisce: View {
    let corpo: CGFloat
    private var altezzaMaiuscola: CGFloat { corpo * 0.71 }

    var body: some View {
        Text("E")
            .font(.system(size: corpo, weight: .bold))
            .tracking(-3)
            .foregroundStyle(Tema.blu)
            .overlay(alignment: .leading) { strisce.offset(x: -corpo * 0.42, y: -corpo * 0.015) }
    }

    /// Tre strisce, una per barra della E (alta, centrale, bassa), di lunghezze diverse.
    private var strisce: some View {
        VStack(alignment: .trailing, spacing: 0) {
            striscia(corpo * 0.34)
            Spacer(minLength: 0)
            striscia(corpo * 0.22)
            Spacer(minLength: 0)
            striscia(corpo * 0.34)
        }
        .frame(width: corpo * 0.36, height: altezzaMaiuscola)
    }

    private func striscia(_ lunghezza: CGFloat) -> some View {
        Capsule().fill(Tema.blu.opacity(0.55)).frame(width: lunghezza, height: corpo * 0.1)
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
