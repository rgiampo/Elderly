import SwiftUI

/// Il logo di una categoria nella schermata "Scegli": oggetti veri da tavolo da gioco (carte, foto, un cartoncino),
/// disegnati con le stesse forme e foto dell'app, un po' inclinati come appoggiati sul tavolo.
struct LogoCategoria: View {
    let categoria: Categoria

    var body: some View {
        ZStack { oggetti }
            .scaleEffect(1.45)   // disegnati piccoli, ingranditi tutti insieme: le proporzioni restano giuste
            .frame(width: 185, height: 150)
            .accessibilityHidden(true)
    }

    @ViewBuilder private var oggetti: some View {
        switch categoria {
        case .memoria:
            // "Trova le coppie": una carta coperta e una girata
            CartaCoperta().rotationEffect(.degrees(-12)).offset(x: -24, y: 3)
            CartaScoperta(forma: .cerchio).rotationEffect(.degrees(9)).offset(x: 24, y: -2)
        case .foto:
            Polaroid(foto: .risorsa("foto_gatto")).rotationEffect(.degrees(-10)).offset(x: -24, y: 5)
            Polaroid(foto: .risorsa("foto_pizza")).rotationEffect(.degrees(7)).offset(x: 24, y: -3)
        case .mente:
            // la chiave di "Simboli e numeri"
            ChiaveSimboli().rotationEffect(.degrees(-4))
        case .crea:
            PolaroidVuota().rotationEffect(.degrees(6))
        }
    }
}

private extension View {
    /// L'ombra di un oggetto appoggiato sul tavolo.
    func appoggiato() -> some View { shadow(color: Tema.testo.opacity(0.28), radius: 4, x: 0, y: 3) }

    /// Il bordo sottile degli oggetti bianchi: sulla scheda bianca altrimenti sparirebbero.
    func bordino(_ raggio: CGFloat) -> some View {
        overlay(RoundedRectangle(cornerRadius: raggio, style: .continuous).stroke(Tema.testo.opacity(0.14), lineWidth: 1))
    }
}

private struct CartaCoperta: View {
    var body: some View {
        let forma = RoundedRectangle(cornerRadius: 9, style: .continuous)
        forma.fill(Tema.blu)
            .overlay(forma.inset(by: 5).stroke(.white.opacity(0.55), lineWidth: 2))
            .overlay(Forma.stella.sagoma.fill(.white.opacity(0.45)).frame(width: 26, height: 26))
            .frame(width: 64, height: 88)
            .appoggiato()
    }
}

private struct CartaScoperta: View {
    let forma: Forma

    var body: some View {
        let carta = RoundedRectangle(cornerRadius: 9, style: .continuous)
        carta.fill(.white)
            .overlay(carta.stroke(Tema.testo.opacity(0.14), lineWidth: 1))
            .overlay(forma.sagoma.fill(forma.colore).frame(width: 36, height: 36))
            .frame(width: 64, height: 88)
            .appoggiato()
    }
}

private struct Polaroid: View {
    let foto: FotoQuiz

    var body: some View {
        FotoView(foto: foto)
            .frame(width: 58, height: 52)
            .clipped()
            .padding(6).padding(.bottom, 12)
            .background(.white)
            .bordino(2)
            .appoggiato()
    }
}

/// Una foto ancora da mettere: il posto tratteggiato e il +.
private struct PolaroidVuota: View {
    var body: some View {
        let posto = RoundedRectangle(cornerRadius: 4, style: .continuous)
        posto.fill(Tema.celeste.opacity(0.45))
            .overlay(posto.stroke(Tema.blu, style: StrokeStyle(lineWidth: 2.5, dash: [6, 4])))
            .overlay(Image(systemName: "plus").font(.system(size: 34, weight: .heavy)).foregroundStyle(Tema.blu))
            .frame(width: 74, height: 66)
            .padding(7).padding(.bottom, 16)
            .background(.white)
            .bordino(2)
            .appoggiato()
    }
}

/// Il cartoncino della chiave: ogni forma con il suo numero.
private struct ChiaveSimboli: View {
    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array([Forma.stella, .quadrato, .triangolo].enumerated()), id: \.offset) { posizione, forma in
                VStack(spacing: 4) {
                    forma.sagoma.fill(forma.colore).frame(width: 26, height: 26)
                    Text("\(posizione + 1)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(Tema.testo)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .bordino(12)
        .appoggiato()
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach(Categoria.allCases) { LogoCategoria(categoria: $0) }
    }
    .padding()
    .background(Tema.celeste)
}
