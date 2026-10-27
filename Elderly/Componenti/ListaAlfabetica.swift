import SwiftUI

/// Elenco di persone in ordine alfabetico, con le lettere come titoli e una barra a destra:
/// si tocca o si scorre su una lettera e l'elenco salta lì (come la rubrica del telefono).
/// Le lettere sono grandi e solo quelle che servono, così si toccano bene.
struct ListaAlfabetica<Riga: View>: View {
    let utenti: [Utente]
    @ViewBuilder let riga: (Utente) -> Riga

    @State private var letteraAttiva: String?

    /// Le persone raggruppate per iniziale del nome, in ordine.
    private var gruppi: [(lettera: String, persone: [Utente])] {
        Dictionary(grouping: utenti) { String($0.nome.prefix(1)).uppercased() }
            .map { (lettera: $0.key, persone: $0.value.sorted { $0.nomeCompleto.localizedCaseInsensitiveCompare($1.nomeCompleto) == .orderedAscending }) }
            .sorted { $0.lettera.localizedCaseInsensitiveCompare($1.lettera) == .orderedAscending }
    }

    var body: some View {
        ScrollViewReader { proxy in
            HStack(alignment: .top, spacing: 16) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16, pinnedViews: []) {
                        ForEach(gruppi, id: \.lettera) { gruppo in
                            Text(gruppo.lettera)
                                .testo(DimensioneTesto.medio)
                                .foregroundStyle(Tema.testoSecondario)
                                .padding(.leading, 12).padding(.top, 8)
                                .id(gruppo.lettera)
                                .accessibilityAddTraits(.isHeader)
                            ForEach(gruppo.persone) { riga($0) }
                        }
                    }
                    .padding(.vertical, 8)
                }

                if gruppi.count > 1 { barra(proxy) }
            }
        }
    }

    /// La barra delle lettere, alta quanto l'elenco e allineata in alto con la prima riga. Le lettere si distribuiscono
    /// in parti uguali (al massimo 72 punti l'una, per toccarle bene). Si tocca una lettera o si trascina il dito lungo la barra.
    private func barra(_ proxy: ScrollViewProxy) -> some View {
        let lettere = gruppi.map(\.lettera)
        return GeometryReader { spazio in
            let altezza = min(72, (spazio.size.height - 12) / CGFloat(lettere.count))
            VStack(spacing: 0) {
                ForEach(lettere, id: \.self) { lettera in
                    Text(lettera)
                        .testo(altezza < 56 ? 28 : DimensioneTesto.normale)
                        .foregroundStyle(letteraAttiva == lettera ? .white : Tema.blu)
                        .frame(width: 60, height: altezza)
                        .background(letteraAttiva == lettera ? Tema.blu : .clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 6).padding(.horizontal, 6)
            .frame(width: 72)
            .vetro(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { valore in
                let posizione = Int((valore.location.y - 6) / altezza)
                guard lettere.indices.contains(posizione), lettere[posizione] != letteraAttiva else { return }
                letteraAttiva = lettere[posizione]
                withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(lettere[posizione], anchor: .top) }
            }.onEnded { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { letteraAttiva = nil }
            })
            .sensoryFeedback(.selection, trigger: letteraAttiva)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(width: 72)
        .accessibilityHidden(true)   // con VoiceOver si scorre l'elenco normalmente
    }
}
