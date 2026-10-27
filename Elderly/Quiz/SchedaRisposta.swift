import SwiftUI

/// Una risposta: solo la foto, a tutta scheda, perché il nome svelerebbe la risposta.
/// Quando è giusta compaiono il nome e la spunta (il colore da solo non basta).
struct SchedaRisposta: View {
    enum Stato { case normale, giusta, sbagliata }

    let risposta: RispostaQuiz
    let stato: Stato

    var body: some View {
        FotoView(foto: risposta.foto)
            .overlay(alignment: .bottom) { if stato == .giusta { nomeSulla } }
            .overlay(alignment: .topTrailing) { if stato == .giusta { spunta } }
            .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous).stroke(Tema.verde, lineWidth: stato == .giusta ? 10 : 0))
            .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)
            .saturation(stato == .sbagliata ? 0 : 1)
            .opacity(stato == .sbagliata ? 0.45 : 1)
            .scaleEffect(stato == .giusta ? 1.02 : 1)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: stato)
    }

    private var nomeSulla: some View {
        Text(risposta.testo)
            .testo(DimensioneTesto.grande)
            .foregroundStyle(.white)
            .lineLimit(1).minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Tema.verde)
    }

    private var spunta: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 64))
            .foregroundStyle(.white, Tema.verde)
            .padding(16)
    }
}

/// Mostra una foto del quiz, che sia nell'app o scelta dall'utente. Riempie tutto lo spazio che ha.
struct FotoView: View {
    let foto: FotoQuiz?

    var body: some View {
        Color(white: 0.92)
            .overlay {
                switch foto {
                case .risorsa(let nome): Image(nome).resizable().scaledToFill()
                case .dati(let dati): immagine(dati)
                case nil: segnaposto
                }
            }
            .clipped()
    }

    @ViewBuilder
    private func immagine(_ dati: Data) -> some View {
        if let uiImage = Immagini.ridotta(da: dati, latoMassimo: Configurazione.latoFotoSalvata) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            segnaposto
        }
    }

    private var segnaposto: some View {
        Image(systemName: "photo").font(.system(size: 60)).foregroundStyle(.secondary)
    }
}
