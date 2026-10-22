import SwiftUI

/// Descrive un gioco configurabile: basta aggiungerne uno a `Gioco.catalogo`.
struct Gioco: Identifiable {
    let id = UUID()
    let titolo: String
    let descrizione: String
    let icona: String
    let colore: Color
    let vista: () -> AnyView

    static let catalogo: [Gioco] = [
        Gioco(
            titolo: "Memoria",
            descrizione: "Trova le coppie uguali",
            icona: "square.grid.2x2.fill",
            colore: .blue,
            vista: { AnyView(GiocoMemoriaView(coppie: 4)) }
        )
    ]
}
