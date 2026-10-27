import SwiftUI
import UIKit

/// Apre la fotocamera del tablet e restituisce la foto scattata.
struct Fotocamera: UIViewControllerRepresentable {
    let alScatto: (Data) -> Void
    @Environment(\.dismiss) private var chiudi

    static var èDisponibile: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controllo = UIImagePickerController()
        controllo.sourceType = .camera
        controllo.delegate = context.coordinator
        return controllo
    }

    func updateUIViewController(_ controllo: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinatore { Coordinatore(self) }

    final class Coordinatore: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let genitore: Fotocamera
        init(_ genitore: Fotocamera) { self.genitore = genitore }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let immagine = info[.originalImage] as? UIImage, let dati = immagine.jpegData(compressionQuality: 0.9) {
                genitore.alScatto(dati)
            }
            genitore.chiudi()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { genitore.chiudi() }
    }
}
