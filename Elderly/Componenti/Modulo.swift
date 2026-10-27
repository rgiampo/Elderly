import SwiftUI

// Pezzi per costruire le schermate in cui si scrive qualcosa (aggiungere una persona, creare un quiz).
// Tutti usano la stessa scala di testi dell'app, gli stessi margini (40) e pulsanti alti almeno 84 punti:
// così tutto resta grande, toccabile e uguale tra una schermata e l'altra, anche cambiando la grandezza nelle Opzioni.

enum MisureModulo {
    static let margine: CGFloat = 40
    static let spazio: CGFloat = 24
    static let altezzaControllo: CGFloat = 84
    static let larghezzaMassima: CGFloat = 1000
}

/// Barra in alto del modulo: "Annulla" a sinistra, il titolo, "Salva" a destra. Il pulsante Salva è verde solo quando si può salvare.
struct IntestazioneModulo: View {
    let titolo: String
    let annulla: () -> Void
    let salva: () -> Void
    let puòSalvare: Bool

    var body: some View {
        HStack(spacing: 24) {
            Button(action: annulla) {
                Text("Annulla")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .padding(.horizontal, 32)
                    .frame(minHeight: MisureModulo.altezzaControllo)
                    .vetro(.white.opacity(0.78))
            }
            .buttonStyle(StilePremuto())

            Text(titolo)
                .testo(DimensioneTesto.grande)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Button(action: salva) {
                Text("Fatto")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(.white)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .padding(.horizontal, 40)
                    .frame(minHeight: MisureModulo.altezzaControllo)
                    .vetro(Tema.verde)
            }
            .buttonStyle(StilePremuto())
            .disabled(!puòSalvare)
            .opacity(puòSalvare ? 1 : 0.4)
        }
        .padding(.horizontal, MisureModulo.margine).padding(.vertical, 12)
        .barraOpaca()
    }
}

/// Un campo di testo grande con il suo nome sopra.
struct CampoTesto: View {
    let titolo: String
    @Binding var testo: String
    var esempio = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titolo).testo(DimensioneTesto.normale).foregroundStyle(Tema.testoSecondario)
            TextField(esempio, text: $testo)
                .testo(DimensioneTesto.medio)
                .foregroundStyle(Tema.testo)
                .padding(.horizontal, 28)
                .frame(minHeight: MisureModulo.altezzaControllo)
                .scheda(raggio: 28)
        }
    }
}

/// Un titolo di sezione e, sotto, il suo contenuto.
struct SezioneModulo<Contenuto: View>: View {
    let titolo: String
    @ViewBuilder let contenuto: Contenuto

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titolo).testo(DimensioneTesto.normale).foregroundStyle(Tema.testoSecondario)
            contenuto
        }
    }
}

/// Due o tre pulsanti grandi tra cui sceglierne uno; quello scelto è pieno di colore.
struct SceltaGrande<Valore: Hashable>: View {
    let opzioni: [(valore: Valore, nome: String)]
    @Binding var scelta: Valore?

    var body: some View {
        HStack(spacing: 16) {
            ForEach(opzioni.indices, id: \.self) { i in
                let selezionata = scelta == opzioni[i].valore
                Button { scelta = opzioni[i].valore } label: {
                    Text(opzioni[i].nome)
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(selezionata ? .white : Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: MisureModulo.altezzaControllo)
                        .vetro(selezionata ? Tema.blu : .white.opacity(0.78), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .buttonStyle(StilePremuto())
                .accessibilityAddTraits(selezionata ? .isSelected : [])
            }
        }
    }
}

/// Un numero con due pulsanti grandi, − e +, ai lati.
struct ContatoreGrande: View {
    @Binding var valore: Int
    let intervallo: ClosedRange<Int>
    var unità = "anni"

    var body: some View {
        HStack(spacing: 24) {
            tasto("minus", "Diminuisci") { valore = max(intervallo.lowerBound, valore - 1) }
            Text("\(valore) \(unità)")
                .testo(DimensioneTesto.grande)
                .foregroundStyle(Tema.testo)
                .lineLimit(1).minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity)
            tasto("plus", "Aumenta") { valore = min(intervallo.upperBound, valore + 1) }
        }
    }

    private func tasto(_ simbolo: String, _ nome: String, azione: @escaping () -> Void) -> some View {
        Button(action: azione) {
            Image(systemName: simbolo)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Tema.testo)
                .frame(width: 96, height: MisureModulo.altezzaControllo)
                .vetro(.white.opacity(0.78))
        }
        .buttonStyle(StilePremuto())
        .accessibilityLabel(nome)
    }
}

/// Contenitore di un modulo: sfondo, barra in alto e contenuto che scorre, con margini uguali ovunque.
struct ModuloView<Contenuto: View>: View {
    let titolo: String
    let annulla: () -> Void
    let salva: () -> Void
    let puòSalvare: Bool
    @ViewBuilder let contenuto: Contenuto

    var body: some View {
        ZStack {
            SfondoCielo()
            VStack(spacing: 0) {
                IntestazioneModulo(titolo: titolo, annulla: annulla, salva: salva, puòSalvare: puòSalvare)
                    .zIndex(1)
                ScrollView {
                    VStack(alignment: .leading, spacing: MisureModulo.spazio) { contenuto }
                        .padding(.horizontal, MisureModulo.margine).padding(.bottom, 60)
                        .frame(maxWidth: MisureModulo.larghezzaMassima)
                        .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}
