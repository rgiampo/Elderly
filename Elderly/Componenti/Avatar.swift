import SwiftUI
import SwiftData

/// Foto tonda della persona, oppure le iniziali se non c'è la foto.
struct Avatar: View {
    let utente: Utente?
    var dimensione: CGFloat = 90

    var body: some View {
        ZStack {
            if let dati = utente?.foto, let immagine = UIImage(data: dati) {
                Image(uiImage: immagine).resizable().scaledToFill()
            } else {
                Circle().fill(.white)
                if let utente, !utente.iniziali.isEmpty {
                    Text(utente.iniziali)
                        .font(.system(size: dimensione * 0.4, weight: .bold, design: .rounded))
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
        .overlay(Circle().stroke(.white, lineWidth: 3))
        .accessibilityHidden(true)
    }
}

/// Mostra chi sta giocando (la persona scelta nella schermata Utenti).
struct ChipUtente: View {
    @AppStorage("utenteAttivo") private var attivo = ""
    @Query private var utenti: [Utente]

    var body: some View {
        if let utente = utenti.first(where: { $0.id.uuidString == attivo }) {
            HStack(spacing: 14) {
                Avatar(utente: utente, dimensione: 64)
                Text(utente.nomeCompleto)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Tema.testo)
            }
            .padding(10).padding(.trailing, 14)
            .glassEffect(.regular, in: .capsule)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Gioca \(utente.nomeCompleto)")
        }
    }
}
