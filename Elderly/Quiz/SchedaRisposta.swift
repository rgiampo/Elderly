import SwiftUI

/// Una risposta: solo la foto, perché il nome svelerebbe la risposta. Quando è giusta compaiono il nome e la spunta (il colore da solo non basta).
struct SchedaRisposta: View {
    enum Stato { case normale, giusta, sbagliata }

    let risposta: RispostaQuiz
    let stato: Stato
    @ScaledMetric(relativeTo: .title) private var altezzaFoto = 340

    private let raggio: CGFloat = 36
    fileprivate let verde = Color(red: 0.05, green: 0.45, blue: 0.22)

    var body: some View {
        FotoView(foto: risposta.foto)
            .frame(height: altezzaFoto)
            .overlay(alignment: .bottom) { nomeSeGiusta }
        .clipShape(RoundedRectangle(cornerRadius: raggio))
        .overlay(RoundedRectangle(cornerRadius: raggio).stroke(verde, lineWidth: stato == .giusta ? 8 : 0))
        .overlay(alignment: .topTrailing) {
            if stato == .giusta {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white, verde)
                    .padding(14)
            }
        }
        .shadow(color: Tema.testo.opacity(0.2), radius: 14, y: 8)
        .saturation(stato == .sbagliata ? 0 : 1)
        .opacity(stato == .sbagliata ? 0.5 : 1)
        .scaleEffect(stato == .giusta ? 1.03 : 1)
        .animation(.spring(duration: 0.35, bounce: 0.3), value: stato)
    }
}

extension SchedaRisposta {
    /// Il nome appare solo dopo aver trovato la risposta giusta.
    @ViewBuilder
    fileprivate var nomeSeGiusta: some View {
        if stato == .giusta {
            Text(risposta.testo)
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(verde)
        }
    }
}

/// Mostra una foto del quiz, che sia nell'app o scelta dall'utente.
struct FotoView: View {
    let foto: FotoQuiz?

    var body: some View {
        Color(white: 0.92)
            .overlay {
                switch foto {
                case .risorsa(let nome): Image(nome).resizable().scaledToFill()
                case .dati(let dati): immagine(dati)
                case nil: Image(systemName: "photo").font(.system(size: 60)).foregroundStyle(.secondary)
                }
            }
            .clipped()
    }

    @ViewBuilder
    private func immagine(_ dati: Data) -> some View {
        if let uiImage = UIImage(data: dati) { Image(uiImage: uiImage).resizable().scaledToFill() }
        else { Image(systemName: "photo").font(.system(size: 60)).foregroundStyle(.secondary) }
    }
}
