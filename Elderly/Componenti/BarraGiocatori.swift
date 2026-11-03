import SwiftUI

/// Mostra chi gioca (una o due persone), chi ha il turno (nel suo colore) e quanti punti ha.
/// Se nessuno ha un nome mostra solo i punti (se ci sono), altrimenti niente.
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
        } else if turno != nil, !punti.isEmpty {
            PuntiSenzaNome(totale: punti.reduce(0, +))
        }
    }
}

/// I punti di chi gioca senza nome: una sola pastiglia con la stella.
private struct PuntiSenzaNome: View {
    let totale: Int

    var body: some View {
        Label("\(totale)", systemImage: "star.fill")
            .testo(DimensioneTesto.normale)
            .foregroundStyle(Tema.testo)
            .padding(.vertical, 10).padding(.horizontal, 20)
            .vetro(.white.opacity(0.78))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(totale) punti")
    }
}

/// Un giocatore: foto, nome, punti. Se è il suo turno si riempie del suo colore.
private struct Pedina: View {
    let giocatore: Partecipante
    let posizione: Int
    let attivo: Bool
    let mostraTurno: Bool
    let punti: Int?

    /// Pieno del suo colore: quando è il suo turno, oppure sempre fuori dalla partita (in "Scegli" si vede chi gioca e di che colore è).
    private var inEvidenza: Bool { mostraTurno ? attivo : true }

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
                    .lineLimit(1).minimumScaleFactor(0.3)
                Spacer(minLength: 12)
                // i punti non si tagliano mai: se manca spazio si rimpicciolisce il nome, non il punteggio
                if !punti.isEmpty { puntiDiTutti.fixedSize().layoutPriority(1) }
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

    /// I punti di ognuno: la sua foto (o le iniziali) e il numero con la stella. Corti, così ci stanno sempre.
    private var puntiDiTutti: some View {
        HStack(spacing: 18) {
            ForEach(Array(giocatori.enumerated()), id: \.element.id) { posizione, g in
                HStack(spacing: 8) {
                    Avatar(utente: g.utente, dimensione: 48)
                    let suoi = posizione < punti.count ? punti[posizione] : 0
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").symbolEffect(.bounce, value: suoi)
                        Text("\(suoi)").contentTransition(.numericText(value: Double(suoi)))
                    }
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .animation(.spring(duration: 0.4), value: suoi)
                }
                .padding(.trailing, 10).padding(4)
                .background(.white.opacity(posizione == turno ? 0.3 : 0.12), in: Capsule())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(g.nome): \(posizione < punti.count ? punti[posizione] : 0) punti")
            }
        }
    }
}
