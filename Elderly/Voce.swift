import AVFoundation
import SwiftUI

/// Legge un testo ad alta voce con la sintesi vocale di iOS, in italiano e piano.
@MainActor @Observable
final class Voce: NSObject, AVSpeechSynthesizerDelegate {
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
        frase.voice = AVSpeechSynthesisVoice(language: "it-IT")
        frase.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        frase.pitchMultiplier = 1.0
        sintetizzatore.speak(frase)
    }

    func ferma() { sintetizzatore.stopSpeaking(at: .immediate) }

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
    @State private var voce = Voce()
    @ScaledMetric(relativeTo: .title) private var icona = 64
    @ScaledMetric(relativeTo: .title) private var altezza = 130

    var body: some View {
        Button { voce.leggi(testo) } label: {
            HStack(spacing: 24) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: icona))
                    .symbolEffect(.variableColor.iterative, isActive: voce.staParlando)
                Text(voce.staParlando ? "Sto parlando…" : "Ascolta come si gioca")
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .minimumScaleFactor(0.6)
            }
            .foregroundStyle(.black.opacity(0.85))
            .frame(maxWidth: .infinity, minHeight: altezza)
        }
        .buttonStyle(.glassProminent)
        .tint(Tema.sole)
        .accessibilityLabel(voce.staParlando ? "Ferma la spiegazione" : "Ascolta come si gioca")
        .accessibilityHint("Una voce spiega le regole")
        .onDisappear { voce.ferma() }
    }
}

enum Istruzioni {
    static let comeSiGioca = "Ciao! Guarda le forme colorate: si accendono e suonano una dopo l'altra. "
        + "Poi tocca le forme nello stesso ordine. Se sbagli non c'è problema: riproviamo insieme. "
        + "Giochiamo!"
}
