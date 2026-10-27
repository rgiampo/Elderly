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

/// Bottone enorme: si preme e una voce spiega a chi non sa leggere.
struct BottoneVoce: View {
    let testo: String
    var etichetta = "Ascolta come si gioca"
    @State private var voce = Voce()
    @ScaledMetric(relativeTo: .title) private var icona = 40
    @ScaledMetric(relativeTo: .title) private var altezza = 88

    var body: some View {
        Button { voce.leggi(testo) } label: {
            HStack(spacing: 16) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: icona))
                    .symbolEffect(.variableColor.iterative, isActive: voce.staParlando)
                Text(voce.staParlando ? "Sto parlando…" : etichetta)
                    .testo(DimensioneTesto.medio, .heavy)
                    .minimumScaleFactor(0.6)
            }
            .foregroundStyle(.black.opacity(0.85))
            .frame(maxWidth: 560, minHeight: altezza)
        }
        .buttonStyle(.glassProminent)
        .tint(Tema.sole)
        .accessibilityLabel(voce.staParlando ? "Ferma la lettura" : etichetta)
        .accessibilityHint("Una voce spiega le regole")
        .onDisappear { voce.ferma() }
    }
}

enum Istruzioni {
    static let comeSiGioca = "Ciao! Guarda le forme colorate: si accendono e suonano una dopo l'altra. "
        + "Poi tocca le forme nello stesso ordine. Se sbagli non c'è problema: riproviamo insieme. "
        + "Giochiamo!"
}
