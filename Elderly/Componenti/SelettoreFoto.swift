import SwiftUI
import PhotosUI

/// Bottone che apre la libreria foto e restituisce l'immagine già ridimensionata (vedi `Immagini`).
/// Si usa sia per la foto di una persona sia per le foto delle risposte dei quiz.
struct SelettoreFoto<Etichetta: View>: View {
    @Binding var foto: Data?
    var latoMassimo: CGFloat = Configurazione.latoFotoSalvata
    @ViewBuilder let etichetta: Etichetta

    @State private var scelta: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $scelta, matching: .images) { etichetta }
            .onChange(of: scelta) { _, nuova in
                Task { if let dati = await ridimensiona(nuova) { foto = dati } }
            }
    }

    private func ridimensiona(_ elemento: PhotosPickerItem?) async -> Data? {
        guard let dati = try? await elemento?.loadTransferable(type: Data.self) else { return nil }
        return Immagini.jpegRidotto(da: dati, latoMassimo: latoMassimo)
    }
}
