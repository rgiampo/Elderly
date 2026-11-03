import SwiftUI

/// Aiuto per scaricare una voce più naturale: rifà passo per passo le schermate di Impostazioni dell'iPad,
/// con un dito che tocca la riga giusta. Si va avanti e indietro con i pulsanti, quando si vuole.
/// shortcut: le schermate sono ridisegnate, non registrate (il simulatore non ha il menu "Voci");
/// se Apple cambia i nomi in Impostazioni vanno aggiornati qui.
struct GuidaVoceView: View {
    @Environment(\.dismiss) private var chiudi
    @State private var passo = 0
    @State private var tocca = false

    private struct Passo {
        let schermata: String          // il titolo della schermata di Impostazioni
        let righe: [String]
        let daToccare: Int             // la riga da toccare
        let spiegazione: String
    }

    private let passi: [Passo] = [
        Passo(schermata: "Schermata Home", righe: ["Foto", "Impostazioni", "Musica", "Elderly"], daToccare: 1,
              spiegazione: "Esci da Elderly e apri l'app Impostazioni (la rotellina grigia)."),
        Passo(schermata: "Impostazioni", righe: ["Generali", "Accessibilità", "Aspetto", "Siri"], daToccare: 1,
              spiegazione: "Tocca «Accessibilità»."),
        Passo(schermata: "Accessibilità", righe: ["VoiceOver", "Schermo e dimensioni testo", "Movimento", "Lettura e voce"], daToccare: 3,
              spiegazione: "Tocca «Lettura e voce»."),
        Passo(schermata: "Lettura e voce", righe: ["Leggi selezione", "Leggi schermo", "Voci", "Velocità"], daToccare: 2,
              spiegazione: "Tocca «Voci»."),
        Passo(schermata: "Voci", righe: ["Inglese", "Italiano", "Spagnolo", "Tedesco"], daToccare: 1,
              spiegazione: "Tocca «Italiano»."),
        Passo(schermata: "Italiano", righe: ["Alice (Migliorata)  ⬇︎", "Luca (Migliorata)  ⬇︎", "Federica (Premium)  ⬇︎", "Alice"], daToccare: 0,
              spiegazione: "Tocca la freccia accanto a una voce «Migliorata» o «Premium» e aspetta che si scarichi. Poi torna in Elderly: la voce si usa da sola."),
    ]

    var body: some View {
        ZStack {
            SfondoCielo()
            GeometryReader { schermo in
            // la colonna a destra è disegnata a misura fissa (600 × 688) e poi rimpicciolita tutta insieme
            // sugli schermi piccoli (iPad mini): l'iPad finto resta proporzionato e i pulsanti stanno sotto
            let s = min(1, schermo.size.height / 688, schermo.size.width * 0.5 / 600)
            HStack(alignment: .top, spacing: 40 * s) {
                // a sinistra la spiegazione grande
                VStack(alignment: .leading, spacing: 24) {
                    Text("Passo \(passo + 1) di \(passi.count)")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testoSecondario)
                    Text(passi[passo].spiegazione)
                        .testo(DimensioneTesto.grande)
                        .foregroundStyle(Tema.testo)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentTransition(.opacity)
                        .accessibilityAddTraits(.isHeader)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                // a destra l'iPad con la schermata di Impostazioni e, sotto, Indietro e Avanti
                VStack(spacing: 28) {
                    SchermoFinto(passo: passi[passo], tocca: tocca)
                        .frame(width: 600, height: 560)
                        .id(passo)
                        .transition(.push(from: .trailing))
                    // due pulsanti della stessa misura, larghi quanto l'iPad: le parole ci stanno intere
                    HStack(spacing: 24) {
                        Button { vai(passo - 1) } label: {
                            Label("Indietro", systemImage: "chevron.left")
                                .testo(DimensioneTesto.medio)
                                .foregroundStyle(Tema.testo)
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .vetro(.white.opacity(0.85))
                        }
                        .disabled(passo == 0).opacity(passo == 0 ? 0.4 : 1)
                        Button { passo == passi.count - 1 ? chiudi() : vai(passo + 1) } label: {
                            Label(passo == passi.count - 1 ? "Ho capito" : "Avanti",
                                  systemImage: passo == passi.count - 1 ? "checkmark" : "chevron.right")
                                .labelStyle(IconaDopo())
                                .testo(DimensioneTesto.medio)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .vetro(Tema.verde)
                        }
                    }
                    .buttonStyle(StilePremuto())
                    .frame(width: 600)
                }
                .frame(width: 600, height: 688)
                .scaleEffect(s, anchor: .topTrailing)
                .frame(width: 600 * s, height: 688 * s, alignment: .topTrailing)
            }
            }
            .padding(.horizontal, 40).padding(.bottom, 32)
        }
        .conIndietro(titolo: "Come scaricare una voce più naturale")
        .task(id: passo) { await animaPasso() }
    }

    private func vai(_ nuovo: Int) {
        guard passi.indices.contains(nuovo) else { return }
        withAnimation(.easeInOut(duration: 0.5)) { passo = nuovo }
    }

    /// Il dito arriva sulla riga e la tocca, poi si ripete finché si resta sul passo.
    private func animaPasso() async {
        tocca = false
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.spring(duration: 0.3)) { tocca = true }
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.easeOut(duration: 0.3)) { tocca = false }
        }
    }

    // MARK: - L'iPad finto

    private struct SchermoFinto: View {
        let passo: Passo
        let tocca: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(passo.schermata)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24).padding(.top, 28).padding(.bottom, 18)
                VStack(spacing: 0) {
                    ForEach(Array(passo.righe.enumerated()), id: \.offset) { n, riga in
                        let giusta = n == passo.daToccare
                        HStack {
                            Text(riga).font(.system(size: 24, weight: giusta ? .semibold : .regular)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 20).frame(height: 72)
                        .background(giusta && tocca ? Color.gray.opacity(0.25) : .white)
                        if n < passo.righe.count - 1 { Divider().padding(.leading, 20) }
                    }
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                // il dito sopra tutta la lista (non dentro la riga, se no la riga sotto lo copre):
                // arriva sulla riga giusta, la tocca e lascia un cerchio, non solo un colore
                .overlay(alignment: .topTrailing) {
                    let centro = CGFloat(passo.daToccare) * 72 + 36
                    ZStack(alignment: .topLeading) {
                        Circle().stroke(Color(hex: 0xE8772E), lineWidth: 6)
                            .frame(width: tocca ? 64 : 16, height: tocca ? 64 : 16)
                            .opacity(tocca ? 1 : 0)
                            .offset(x: tocca ? -32 : -8, y: tocca ? -32 : -8)
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color(hex: 0xE8772E), .white)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                            .offset(x: -14, y: tocca ? -6 : 34)
                    }
                    .offset(x: -110, y: centro)
                    .allowsHitTesting(false)
                }
                .padding(.horizontal, 18)
                Spacer()
            }
            .background(Color(white: 0.95))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            // la cornice nera dell'iPad
            .padding(16)
            .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: Tema.testo.opacity(0.3), radius: 18, y: 10)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Schermata \(passo.schermata): toccare \(passo.righe[passo.daToccare])")
        }
    }
}

/// "Avanti ›": il testo e poi la freccia, che indica dove si va.
private struct IconaDopo: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) { configuration.title; configuration.icon }
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { GuidaVoceView() }
}
