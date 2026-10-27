import UIKit
import ImageIO

/// Funzioni per tenere le foto della giusta grandezza: né enormi in memoria, né sgranate a schermo.
enum Immagini {
    /// Rimpicciolisce una foto in modo che il lato più lungo non superi `latoMassimo` pixel.
    /// Il risultato è un JPEG leggero, con l'orientamento già corretto.
    static func jpegRidotto(da dati: Data, latoMassimo: CGFloat, qualita: CGFloat = 0.8) -> Data? {
        ridotta(da: dati, latoMassimo: latoMassimo)?.jpegData(compressionQuality: qualita)
    }

    /// Apre la foto già rimpicciolita, senza decodificarla tutta: veloce anche con foto da 12 megapixel.
    static func ridotta(da dati: Data, latoMassimo: CGFloat) -> UIImage? {
        guard let sorgente = CGImageSourceCreateWithData(dati as CFData, nil) else { return nil }
        let opzioni: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,   // raddrizza le foto scattate in verticale
            kCGImageSourceThumbnailMaxPixelSize: latoMassimo,
            kCGImageSourceShouldCacheImmediately: true,
        ]
        guard let immagine = CGImageSourceCreateThumbnailAtIndex(sorgente, 0, opzioni as CFDictionary) else { return nil }
        return UIImage(cgImage: immagine)
    }
}
