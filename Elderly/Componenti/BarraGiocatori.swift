import SwiftUI

/// Mostra chi gioca (una o due persone), chi ha il turno (nel suo colore) e quanti punti ha.
/// Se nessuno ha un nome non mostra niente.
struct BarraGiocatori: View {
    let giocatori: [Partecipante]
    var turno: Int?            // chi ha il turno; nil quando non si sta giocando
    var punti: [Int] = []

    var body: some View {
        if let turno, giocatori.count > 1, giocatori.indices.contains(turno), giocatori[turno].haNome {
            // con due persone in partita: un grande banner colorato nella barra in alto, con chi tocca e i punti di tutti
            BannerTurno(giocatori: giocatori, turno: turno, punti: punti, altezza: 92)
        } else if giocatori.contains(where: \.haNome) {
            HStack(spacing: 16) {
                ForEach(Array(giocatori.enumerated()), id: \.element.id) { posizione, giocatore in
                    Pedina(giocatore: giocatore,
                           posizione: posizione,
                           attivo: posizione == turno,
                           mostraTurno: turno != nil && giocatori.count > 1,
                           punti: posizione < punti.count ? punti[posizione] : nil)
                }
            }
        }
    }
}

/// Un giocatore: foto, nome, punti. Se è il suo turno si riempie del suo colore.
private struct Pedina: View {
    let giocatore: Partecipante
    let posizione: Int
    let attivo: Bool
    let mostraTurno: Bool
    let punti: Int?

    private var inEvidenza: Bool { mostraTurno && attivo }

    var body: some View {
        HStack(spacing: 14) {
            Avatar(utente: giocatore.utente, dimensione: 64)
            Text(giocatore.nome)
                .testo(DimensioneTesto.normale)
                .lineLimit(1)
            if let punti {
                Label("\(punti)", systemImage: "star.fill")
                    .testo(DimensioneTesto.normale)
            }
        }
        .foregroundStyle(inEvidenza ? .white : Tema.testo)
        .fixedSize()
        .layoutPriority(1)
        .padding(10).padding(.trailing, 14)
        .vetro(inEvidenza ? Tema.coloreGiocatore(posizione) : .white.opacity(mostraTurno ? 0.45 : 0.78))
        .scaleEffect(inEvidenza ? 1.04 : 1)
        .animation(.spring(duration: 0.35, bounce: 0.3), value: attivo)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(etichetta)
    }

    private var etichetta: String {
        var testo = giocatore.nome
        if inEvidenza { testo += ", tocca a te" }
        if let punti { testo += ", \(punti) punti" }
        return testo
    }
}

/// Il banner grande del turno: dice chiaramente di chi tocca, con la sua foto e il suo colore,
/// e a destra i punti di tutti. Compare solo se giocano due persone con il nome.
struct BannerTurno: View {
    let giocatori: [Partecipante]
    let turno: Int
    var punti: [Int] = []
    var altezza: CGFloat = 120

    var body: some View {
        if giocatori.count > 1, giocatori.indices.contains(turno), giocatori[turno].haNome {
            let giocatore = giocatori[turno]
            HStack(spacing: 24) {
                Avatar(utente: giocatore.utente, dimensione: altezza - 24)
                Text("Tocca a \(giocatore.nome)")
                    .testo(DimensioneTesto.titolo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Spacer(minLength: 12)
                if !punti.isEmpty { puntiDiTutti }
            }
            .foregroundStyle(.white)
            .padding(12).padding(.trailing, 28)
            .frame(maxWidth: .infinity, minHeight: altezza)
            .vetro(Tema.coloreGiocatore(turno))
            .id(turno)   // a ogni cambio di turno il banner scivola via e ne entra uno nuovo
            .transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading).combined(with: .opacity)))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Tocca a \(giocatore.nome)")
            .accessibilityAddTraits(.isHeader)
        }
    }

    /// "Pino 2   Rosa 1": i punti di ognuno, con il nome.
    private var puntiDiTutti: some View {
        HStack(spacing: 22) {
            ForEach(Array(giocatori.enumerated()), id: \.element.id) { posizione, g in
                Label("\(g.nome) \(posizione < punti.count ? punti[posizione] : 0)", systemImage: "star.fill")
                    .testo(DimensioneTesto.medio)
                    .lineLimit(1)
                    .opacity(posizione == turno ? 1 : 0.7)
            }
        }
    }
}
