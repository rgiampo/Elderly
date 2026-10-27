import SwiftUI

/// Il tocco "affonda" leggermente, così si capisce che il bottone ha risposto.
struct StilePremuto: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())   // tutta l'area del pulsante risponde, non solo il testo
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

/// Pulsante principale: vetro colorato a pillola, testo bianco enorme, testo centrato.
struct PulsantePrincipale: View {
    let titolo: String
    var colore: Color = Tema.blu
    var altezza: CGFloat = 120

    var body: some View {
        Text(titolo)
            .testo(DimensioneTesto.grande)
            .foregroundStyle(.white)
            .lineLimit(1).minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, minHeight: altezza)
            .vetro(colore)
    }
}

/// Pulsante secondario: vetro chiaro a pillola, testo scuro enorme, testo centrato.
struct PulsanteSecondario: View {
    let titolo: String
    var altezza: CGFloat = 120

    var body: some View {
        Text(titolo)
            .testo(DimensioneTesto.grande)
            .foregroundStyle(Tema.testo)
            .lineLimit(1).minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, minHeight: altezza)
            .vetro(.white.opacity(0.78))
    }
}

/// Barra in alto con un grande "Indietro" (il pulsante piccolo di sistema è difficile da toccare).
/// Si usa su tutte le schermate tranne la prima.
struct BarraIndietro<Destra: View>: ViewModifier {
    var titolo: String?
    let destra: Destra
    @Environment(\.dismiss) private var chiudi

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack(spacing: 24) {
                    Button { chiudi() } label: {
                        Label("Indietro", systemImage: "chevron.left")
                            .testo(DimensioneTesto.medio)
                            .foregroundStyle(Tema.testo)
                            .padding(.horizontal, 32)
                            .frame(minHeight: 84)
                            .vetro(.white.opacity(0.78))
                    }
                    .buttonStyle(StilePremuto())
                    .accessibilityLabel("Indietro")

                    if let titolo {
                        Text(titolo)
                            .testo(DimensioneTesto.grande)
                            .foregroundStyle(Tema.testo)
                            .lineLimit(1).minimumScaleFactor(0.5)
                            .accessibilityAddTraits(.isHeader)
                    }
                    Spacer(minLength: 0)
                    destra
                }
                .padding(.horizontal, 40).padding(.top, 12).padding(.bottom, 12)
                .barraOpaca()
            }
    }
}

extension View {
    /// Aggiunge in alto il grande "Indietro", un titolo e, a destra, quello che serve alla schermata (per esempio i giocatori).
    func conIndietro<Destra: View>(titolo: String? = nil, @ViewBuilder destra: () -> Destra = { EmptyView() }) -> some View {
        modifier(BarraIndietro(titolo: titolo, destra: destra()))
    }
}

extension View {
    /// Sfondo pieno per le barre in alto: quando la lista scorre, i contenuti passano sotto la barra senza sovrapporsi al titolo.
    func barraOpaca() -> some View {
        background {
            Tema.celeste
                .shadow(color: Tema.testo.opacity(0.12), radius: 8, y: 4)
                .ignoresSafeArea(edges: .top)
        }
    }
}
