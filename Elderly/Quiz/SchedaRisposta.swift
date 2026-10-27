import SwiftUI

/// Una risposta: solo la foto, a tutta scheda, perché il nome svelerebbe la risposta.
/// Quando è giusta compaiono il nome e la spunta (il colore da solo non basta).
struct SchedaRisposta: View {
    enum Stato { case normale, giusta, sbagliata }

    let risposta: RispostaQuiz
    let stato: Stato

    var body: some View {
        FotoView(foto: risposta.foto, intera: true)
            .aspectRatio(Configurazione.formaFoto, contentMode: .fit)
            .overlay(alignment: .bottom) { if stato == .giusta { nomeSulla } }
            .overlay(alignment: .topTrailing) { if stato == .giusta { spunta } else if stato == .sbagliata { croce } }
            .overlay { if stato == .sbagliata { Tema.rosso.opacity(0.5).allowsHitTesting(false) } }
            .clipShape(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous).stroke(stato == .sbagliata ? Tema.rosso : Tema.verde, lineWidth: stato == .normale ? 0 : 10))
            .shadow(color: Tema.testo.opacity(0.2), radius: 12, y: 6)

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

    private var croce: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 64))
            .foregroundStyle(.white, Tema.rosso)
            .padding(16)
    }

    private var spunta: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 64))
            .foregroundStyle(.white, Tema.verde)
            .padding(16)
    }
}

/// Mostra una foto del quiz, che sia nell'app o scelta dall'utente. Riempie tutto lo spazio che ha.
/// Con `intera` la foto si vede tutta, senza tagli: i bordi vuoti si riempiono con la stessa foto sfocata.
struct FotoView: View {
    let foto: FotoQuiz?
    var intera = false

    var body: some View {
        Color(white: 0.92)
            .overlay {
                if intera {
                    ZStack {
                        // lo sfondo sfocato sta in un riquadro che non cambia la misura (altrimenti la foto "fit" si allargherebbe)
                        Color.clear
                            .overlay { immagine(.fill).blur(radius: 28).scaleEffect(1.15).opacity(0.9) }
                            .clipped()
                        immagine(.fit)
                    }
                } else {
                    immagine(.fill)
                }
            }
            .clipped()
    }

    @ViewBuilder
    private func immagine(_ modo: ContentMode) -> some View {
        switch foto {
        case .risorsa(let nome):
            Image(nome).resizable().aspectRatio(contentMode: modo)
        case .dati(let dati):
            if let uiImage = Immagini.ridotta(da: dati, latoMassimo: Configurazione.latoFotoSalvata) {
                Image(uiImage: uiImage).resizable().aspectRatio(contentMode: modo)
            } else { segnaposto }
        case nil:
            segnaposto
        }
    }

    private var segnaposto: some View {
        Image(systemName: "photo").font(.system(size: 60)).foregroundStyle(.secondary)
    }
}
