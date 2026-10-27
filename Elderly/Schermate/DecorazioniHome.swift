import SwiftUI

/// Decorazioni della prima schermata: le forme del gioco, grandi e morbide, che galleggiano piano sullo sfondo.
/// Si muovono in modo ben visibile, con un'ombra morbida. Restano ferme se l'utente riduce i movimenti. Non si toccano e non sono lette da VoiceOver.
struct DecorazioniHome: View {
    @Environment(\.accessibilityReduceMotion) private var pocoMovimento
    @State private var inMovimento = false

    /// Dove stanno (in percentuale dello schermo), quanto sono grandi e quanto si muovono.
    private struct Pezzo {
        let forma: Forma
        let x: CGFloat, y: CGFloat
        let lato: CGFloat
        let rotazione: Double
        let spostamento: CGSize
        let durata: Double
        var colore: Color { Tema.azzurro.opacity(0.14 + Double(lato) / 1800) }   // più grandi = un po' più marcate
    }

    /// Quanto si muovono rispetto ai valori dei pezzi (più alto = più evidente).
    private let ampiezza: CGFloat = 1.6

    private let pezzi: [Pezzo] = [
        Pezzo(forma: .cerchio,    x: 0.10, y: 0.18, lato: 220, rotazione: 0,   spostamento: CGSize(width: 24, height: 38),  durata: 7),
        Pezzo(forma: .triangolo,  x: 0.90, y: 0.16, lato: 190, rotazione: 14,  spostamento: CGSize(width: -30, height: 26), durata: 8),
        Pezzo(forma: .stella,     x: 0.07, y: 0.80, lato: 200, rotazione: -10, spostamento: CGSize(width: 34, height: -30), durata: 9),
        Pezzo(forma: .quadrato,   x: 0.92, y: 0.84, lato: 170, rotazione: 12,  spostamento: CGSize(width: -26, height: -34), durata: 7.5),
        Pezzo(forma: .cuore,      x: 0.82, y: 0.50, lato: 120, rotazione: 8,   spostamento: CGSize(width: 18, height: 30),  durata: 6.5),
        Pezzo(forma: .cerchio,    x: 0.17, y: 0.52, lato: 90,  rotazione: 0,   spostamento: CGSize(width: -16, height: 24), durata: 6),
    ]

    var body: some View {
        GeometryReader { spazio in
            ForEach(pezzi.indices, id: \.self) { i in
                let p = pezzi[i]
                p.forma.sagoma
                    .fill(p.colore)
                    .frame(width: p.lato, height: p.lato)
                    .rotationEffect(.degrees(p.rotazione + (inMovimento ? 18 : -18)))
                    .shadow(color: Tema.notte.opacity(0.22), radius: 18, x: 0, y: 14)
                    .scaleEffect(inMovimento ? 1.08 : 0.94)
                    .offset(x: inMovimento ? p.spostamento.width * ampiezza : 0, y: inMovimento ? p.spostamento.height * ampiezza : 0)
                    .position(x: p.x * spazio.size.width, y: p.y * spazio.size.height)
                    .animation(pocoMovimento ? nil : .easeInOut(duration: p.durata).repeatForever(autoreverses: true), value: inMovimento)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { inMovimento = true }
    }
}
