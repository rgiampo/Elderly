import AVFoundation
import SwiftUI

/// Legge un testo ad alta voce con la sintesi vocale di iOS, in italiano e piano.
@MainActor @Observable
final class Voce: NSObject, AVSpeechSynthesizerDelegate {
    /// Dove si salva la voce scelta nelle Opzioni (vuoto = la migliore disponibile).
    static let chiaveVoceScelta = "voceScelta"

    private let sintetizzatore = AVSpeechSynthesizer()
    private(set) var staParlando = false

    override init() {
        super.init()
        sintetizzatore.delegate = self
    }

    /// Un secondo tocco mentre sta parlando la ferma.
    func leggi(_ testo: String) {
        if sintetizzatore.isSpeaking {
            sintetizzatore.stopSpeaking(at: .immediate)
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
        let frase = AVSpeechUtterance(string: testo)
        frase.voice = Self.voceDaUsare()
        frase.rate = AVSpeechUtteranceDefaultSpeechRate * Configurazione.velocitaVoce
        frase.preUtteranceDelay = 0.2
        sintetizzatore.speak(frase)
    }

    func ferma() { sintetizzatore.stopSpeaking(at: .immediate) }

    // MARK: - Scelta della voce

    /// Le voci italiane naturali, dalla migliore alla peggiore. Le voci "robot" (Eloquence) e quelle di
    /// novità sono escluse: sono le meno piacevoli da ascoltare.
    static func vociItaliane() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == "it-IT" }
            .filter { !$0.identifier.contains("eloquence") && !$0.identifier.contains("speech.synthesis.voice") }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
    }

    static func descrizione(della voce: AVSpeechSynthesisVoice) -> String {
        switch voce.quality {
        case .premium: "\(voce.name) (qualità alta)"
        case .enhanced: "\(voce.name) (qualità migliorata)"
        default: voce.name
        }
    }

    /// La voce scelta nelle Opzioni; se non c'è, la migliore tra quelle installate.
    static func voceDaUsare() -> AVSpeechSynthesisVoice? {
        let scelta = UserDefaults.standard.string(forKey: chiaveVoceScelta) ?? ""
        return AVSpeechSynthesisVoice(identifier: scelta) ?? vociItaliane().first ?? AVSpeechSynthesisVoice(language: "it-IT")
    }

    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didStart u: AVSpeechUtterance) {
        Task { @MainActor in staParlando = true }
    }
    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish u: AVSpeechUtterance) {
        Task { @MainActor in staParlando = false }
    }
    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel u: AVSpeechUtterance) {
        Task { @MainActor in staParlando = false }
    }
}

/// Bottone che legge ad alta voce un testo, per chi non sa leggere. Un secondo tocco ferma la voce.
struct BottoneVoce: View {
    let testo: String
    var etichetta = "Ascolta"
    var altezza: CGFloat = 84
    @State private var voce = Voce()

    var body: some View {
        Button { voce.leggi(testo) } label: {
            HStack(spacing: 14) {
                // Icone semplici e ferme: niente animazioni che possono scattare
                Image(systemName: voce.staParlando ? "stop.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 34, weight: .bold))
                    .frame(width: 44)
                Text(voce.staParlando ? "Ferma" : etichetta)
                    .testo(DimensioneTesto.medio)
                    .lineLimit(1).minimumScaleFactor(0.5)
            }
            .foregroundStyle(Tema.testo)
            .padding(.horizontal, 32)
            .frame(minHeight: altezza)
            .vetro(Tema.giallo)
        }
        .buttonStyle(StilePremuto())
        .accessibilityLabel(voce.staParlando ? "Ferma la lettura" : etichetta)
        .onDisappear { voce.ferma() }
    }
}

/// I testi che la voce legge per spiegare ogni gioco.
enum Istruzioni {
    static let forme = "Guarda le forme colorate: si accendono e suonano una dopo l'altra. "
        + "Poi tocca le forme nello stesso ordine. Se sbagli non c'è problema: riproviamo insieme."
    static let coppie = "Tocca due carte per girarle. Se le due foto sono uguali, hai trovato una coppia. "
        + "Se sono diverse, si rigirano: prova a ricordare dove sono."
    static let sìNo = "Guarda la foto e rispondi alla domanda. "
        + "Tocca il cerchio verde per dire sì, il triangolo rosso per dire no."
}
