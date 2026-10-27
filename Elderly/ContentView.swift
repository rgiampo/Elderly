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
            // "E" azzurra con le strisce ai lati, come linee di velocità, poi il resto del nome
            HStack(spacing: 0) {
                EConStrisce(corpo: 150)
                Text("lderly")
                    .font(.system(size: 150, weight: .bold))
                    .tracking(-3)
                    .foregroundStyle(Tema.testo)
            }
            .padding(.leading, 150 * 0.3)   // lo spazio delle strisce a sinistra: il nome resta al centro della linea sotto
            .shadow(color: Tema.testo.opacity(0.22), radius: 14, y: 10)
            .lineLimit(1).minimumScaleFactor(0.4)
            .opacity(entrato ? 1 : 0)
            .offset(y: entrato ? 0 : 30)
            .animation(.spring(duration: 0.7, bounce: 0.3), value: entrato)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Elderly")
            .accessibilityAddTraits(.isHeader)

            StrisciaV()
                .trim(from: 0, to: entrato ? 1 : 0)
                .stroke(Tema.blu, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .frame(height: 40)
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

/// Una linea orizzontale con, al centro, una piccola "v" morbida: ——v——
private struct StrisciaV: Shape {
    func path(in rect: CGRect) -> Path {
        let y = rect.minY + rect.height * 0.25            // altezza della linea
        let fondo = rect.maxY                              // punta della "v"
        let centro = rect.midX
        let apertura = rect.width * 0.09                   // quanto è larga la "v"
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: y))
        p.addLine(to: CGPoint(x: centro - apertura * 1.6, y: y))
        p.addQuadCurve(to: CGPoint(x: centro, y: fondo), control: CGPoint(x: centro - apertura * 0.5, y: y))
        p.addQuadCurve(to: CGPoint(x: centro + apertura * 1.6, y: y), control: CGPoint(x: centro + apertura * 0.5, y: y))
        p.addLine(to: CGPoint(x: rect.maxX, y: y))
        return p
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
