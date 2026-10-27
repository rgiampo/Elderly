import SwiftUI

/// Foto tonda della persona, oppure le iniziali se non c'è la foto.
struct Avatar: View {
    let utente: Utente?
    var dimensione: CGFloat = 90

    var body: some View {
        ZStack {
            if let dati = utente?.foto, let immagine = Immagini.ridotta(da: dati, latoMassimo: dimensione * 3) {
                Image(uiImage: immagine).resizable().scaledToFill()
            } else {
                Circle().fill(Tema.celeste.opacity(0.6))
                if let utente, !utente.iniziali.isEmpty {
                    Text(utente.iniziali)
                        .font(.system(size: dimensione * 0.4, weight: .bold))
                        .foregroundStyle(Tema.testo)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: dimensione * 0.45))
                        .foregroundStyle(Tema.testo)
                }
            }
        }
        .frame(width: dimensione, height: dimensione)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
