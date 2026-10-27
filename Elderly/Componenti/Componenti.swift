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

/// Barra in alto: la freccia per tornare indietro (tonda e grande), il titolo e, a destra, quello che serve alla schermata.
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
                        Image(systemName: "chevron.left")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundStyle(Tema.testo)
                            .frame(width: 88, height: 88)
                            .vetro(.white.opacity(0.85), in: Circle())
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
                .padding(.horizontal, 40).padding(.top, 26).padding(.bottom, 18)
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
    /// Sfondo delle barre in alto: pieno dove c'è il testo, poi sfuma. I contenuti che scorrono passano sotto senza toccare il titolo.
    func barraOpaca() -> some View {
        background {
            LinearGradient(stops: [.init(color: Tema.celeste, location: 0),
                                   .init(color: Tema.celeste, location: 0.72),
                                   .init(color: Tema.celeste.opacity(0), location: 1)],
                           startPoint: .top, endPoint: .bottom)
                .padding(.bottom, -14)
                .ignoresSafeArea(edges: .top)
        }
    }
}

