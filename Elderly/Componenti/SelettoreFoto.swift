import SwiftUI
import PhotosUI

/// Bottone che apre la libreria foto e restituisce l'immagine già ridimensionata.
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

    /// Rimpicciolisce la foto: bastano poche centinaia di pixel e il database resta leggero.
    private func ridimensiona(_ elemento: PhotosPickerItem?) async -> Data? {
        guard let dati = try? await elemento?.loadTransferable(type: Data.self),
              let immagine = UIImage(data: dati) else { return nil }
        let lato = min(immagine.size.width, immagine.size.height)
        guard lato > 0 else { return nil }
        let scala = min(1, latoMassimo / lato)
        let dimensione = CGSize(width: immagine.size.width * scala, height: immagine.size.height * scala)
        return UIGraphicsImageRenderer(size: dimensione).jpegData(withCompressionQuality: 0.8) { _ in
            immagine.draw(in: CGRect(origin: .zero, size: dimensione))
        }
    }
}
