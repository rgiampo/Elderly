import SwiftUI
import UIKit

/// Apre la fotocamera dell'iPad e restituisce la foto scattata.
/// Per le foto delle persone mostra sopra l'inquadratura la sagoma di testa e spalle, con un consiglio.
struct Fotocamera: UIViewControllerRepresentable {
    var sagomaPersona = false
    let alScatto: (Data) -> Void
    @Environment(\.dismiss) private var chiudi

    static var èDisponibile: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controllo = UIImagePickerController()
        controllo.sourceType = .camera
        controllo.delegate = context.coordinator
        if sagomaPersona {
            let sopra = UIHostingController(rootView: GuidaScatto())
            sopra.view.backgroundColor = .clear
            sopra.view.isUserInteractionEnabled = false   // i tocchi passano ai pulsanti della fotocamera
            sopra.view.frame = UIScreen.main.bounds
            sopra.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controllo.cameraOverlayView = sopra.view
            context.coordinator.guida = sopra
        }
        return controllo
    }

    func updateUIViewController(_ controllo: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinatore { Coordinatore(self) }

    final class Coordinatore: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let genitore: Fotocamera
        var guida: UIViewController?     // tenuto in vita finché la fotocamera è aperta
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

/// Sopra l'inquadratura: la sagoma tratteggiata di testa e spalle e, in alto, cosa fare.
private struct GuidaScatto: View {
    var body: some View {
        GeometryReader { schermo in
            let altezza = min(schermo.size.height * 0.62, schermo.size.width * 0.7)
            VStack(spacing: 20) {
                Text("Metti il viso dentro la sagoma")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28).padding(.vertical, 14)
                    .background(.black.opacity(0.55), in: Capsule())
                SagomaPersona()
                    .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [18, 12]))
                    .shadow(color: .black.opacity(0.5), radius: 6)
                    .frame(width: altezza * 0.85, height: altezza)
                Text("Tieni l'iPad fermo, poi tocca il pulsante bianco")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 10)
                    .background(.black.opacity(0.55), in: Capsule())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityHidden(true)
    }
}

/// Testa (un ovale) e spalle (un arco largo), come nelle foto per i documenti.
private struct SagomaPersona: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let testa = CGRect(x: r.midX - r.width * 0.26, y: r.minY, width: r.width * 0.52, height: r.height * 0.6)
        p.addEllipse(in: testa)
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.maxX, y: r.maxY),
                   control1: CGPoint(x: r.minX + r.width * 0.05, y: r.minY + r.height * 0.62),
                   control2: CGPoint(x: r.maxX - r.width * 0.05, y: r.minY + r.height * 0.62))
        return p
    }
}

#Preview(traits: .landscapeLeft) {
    GuidaScatto().background(.gray)
}
