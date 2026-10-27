import SwiftUI

/// Il disegno che spiega "Trova le coppie": due foto UGUALI unite da un segno di uguale verde, e sotto due carte coperte.
/// Si capisce subito: bisogna trovare le due carte che hanno la stessa foto.
struct IllustrazioneCoppia: View {
    var foto: FotoQuiz = .risorsa("foto_marinara")
    var conCarteCoperte = true

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                HStack(spacing: 36) {
                    carta
                    carta
                }
                // il segno "uguale" tra le due foto
                Text("=")
                    .font(.system(size: 64, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 92, height: 92)
                    .background(Tema.verde, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 6))
            }

            if conCarteCoperte {
                HStack(spacing: 36) {
                    coperta
                    coperta
                }
                .opacity(0.9)
            }
        }
        .accessibilityHidden(true)
    }

    private var carta: some View {
        FotoView(foto: foto, intera: false)
            .aspectRatio(1.3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Tema.verde, lineWidth: 7))
    }

    private var coperta: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Tema.blu)
            .aspectRatio(1.3, contentMode: .fit)
            .overlay(Text("?").testo(DimensioneTesto.grande).foregroundStyle(.white))
    }
}
