import SwiftUI

/// Mostra chi gioca (una o due persone), chi ha il turno e quanti punti ha.
/// Se nessuno ha un nome non mostra niente.
struct BarraGiocatori: View {
    let giocatori: [Partecipante]
    var turno: Int?            // chi ha il turno; nil quando non si sta giocando (es. nei menu)
    var punti: [Int] = []

    var body: some View {
        if giocatori.contains(where: \.haNome) {
            HStack(spacing: 16) {
                ForEach(Array(giocatori.enumerated()), id: \.element.id) { posizione, giocatore in
                    Pedina(giocatore: giocatore,
                           attivo: posizione == turno,
                           mostraTurno: turno != nil && giocatori.count > 1,
                           punti: posizione < punti.count ? punti[posizione] : nil)
                }
            }
        }
    }
}

/// Un giocatore: foto, nome e, se è il suo turno, la scritta "Tocca a te".
private struct Pedina: View {
    let giocatore: Partecipante
    let attivo: Bool
    let mostraTurno: Bool
    let punti: Int?

    var body: some View {
        HStack(spacing: 14) {
            Avatar(utente: giocatore.utente, dimensione: 68)
            VStack(alignment: .leading, spacing: 2) {
                Text(giocatore.nome)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                if mostraTurno && attivo {
                    Text("Tocca a te")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Tema.azzurroProfondo)
                }
            }
            if let punti {
                Label("\(punti)", systemImage: "star.fill")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Tema.testo)
            }
        }
        .foregroundStyle(Tema.testo)
        .padding(10).padding(.trailing, 16)
        .background(.white.opacity(mostraTurno && !attivo ? 0.4 : 0.95), in: .capsule)
        .overlay(Capsule().stroke(Tema.azzurroProfondo, lineWidth: mostraTurno && attivo ? 4 : 0))
        .animation(.spring(duration: 0.3), value: attivo)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(etichetta)
    }

    private var etichetta: String {
        var testo = giocatore.nome
        if mostraTurno && attivo { testo += ", tocca a te" }
        if let punti { testo += ", \(punti) punti" }
        return testo
    }
}
