import SwiftUI

/// La prima schermata: il logo, il titolo e tre pulsanti enormi. All'apertura tutto entra in sequenza.
struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @State private var entrato = false

    var body: some View {
        NavigationStack {
            ZStack {
                SfondoCielo()
                DecorazioniHome()

                VStack(spacing: 56) {
                    Titolo(entrato: entrato)

                    VStack(spacing: 20) {
                        NavigationLink(destination: ChiGiocaView()) {
                            PulsantePrincipale(titolo: "Gioca", altezza: 130)
                        }
                        .appari(entrato, ritardo: 0.3)
                        NavigationLink(destination: UtentiView()) {
                            PulsanteSecondario(titolo: "Utenti", altezza: 110)
                        }
                        .appari(entrato, ritardo: 0.45)
                        NavigationLink(destination: OpzioniView()) {
                            PulsanteSecondario(titolo: "Opzioni", altezza: 110)
                        }
                        .appari(entrato, ritardo: 0.6)
                    }
                    .buttonStyle(StilePremuto())
                    .frame(maxWidth: 640)
                }
                .padding(40)
            }
        }
        .onAppear {
            if pocoMovimento { entrato = true } else { withAnimation { entrato = true } }
        }
    }
}

extension View {
    /// Entra dal basso e diventa visibile, con un piccolo ritardo (per far comparire le cose una dopo l'altra).
    fileprivate func appari(_ entrato: Bool, ritardo: Double) -> some View {
        opacity(entrato ? 1 : 0)
            .offset(y: entrato ? 0 : 40)
            .animation(.spring(duration: 0.7, bounce: 0.3).delay(ritardo), value: entrato)
    }
}

/// Il nome dell'app, grande, con sotto una striscia con una piccola "v" che si disegna da sinistra a destra.
/// È largo quanto i pulsanti. (Il logo con i due nonni resta l'icona dell'app.)
private struct Titolo: View {
    let entrato: Bool

    var body: some View {
        VStack(spacing: 10) {
            // il nome in San Francisco bold; sotto, la linea con la "v" e i ghirigori ai lati
            Text("Elderly")
                .font(.system(size: 150, weight: .regular))
                .tracking(-3)
                .foregroundStyle(Tema.testo)
                .shadow(color: Tema.testo.opacity(0.22), radius: 14, y: 10)
                .lineLimit(1).minimumScaleFactor(0.4)
                .opacity(entrato ? 1 : 0)
                .offset(y: entrato ? 0 : 30)
                .animation(.spring(duration: 0.7, bounce: 0.3), value: entrato)
                .accessibilityAddTraits(.isHeader)

            Ghirigoro()
                .trim(from: 0, to: entrato ? 1 : 0)
                .stroke(Tema.blu, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .frame(height: 80)
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
