import AVFoundation

/// Note morbide tipo marimba, generate nel codice: nessun file audio.
final class Sintetizzatore {
    static let condiviso = Sintetizzatore()

    private let frequenzaCampionamento = 44100.0
    private var voci: [Double: [AVAudioPlayer]] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func suona(_ frequenza: Double, volume: Float = 0.8) {
        // L'interruttore "Suoni" è nelle Opzioni; di base è acceso.
        guard UserDefaults.standard.object(forKey: "suoniAttivi") as? Bool ?? true else { return }
        if voci[frequenza] == nil {
            // due lettori per nota: la stessa nota può risuonare mentre l'eco della precedente svanisce
            let dati = wav(per: frequenza)
            voci[frequenza] = (0..<2).compactMap { _ in try? AVAudioPlayer(data: dati) }
            voci[frequenza]?.forEach { $0.prepareToPlay() }
        }
        guard var lettori = voci[frequenza], !lettori.isEmpty else { return }
        let lettore = lettori.removeFirst()
        lettori.append(lettore)
        voci[frequenza] = lettori
        lettore.volume = volume
        lettore.currentTime = 0
        lettore.play()
    }

    /// Tre note ascendenti (do, mi, sol) per festeggiare una risposta giusta.
    func accordoDiFesta() {
        for (n, nota) in [523.25, 659.25, 783.99].enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(n) * 0.12) { self.suona(nota, volume: 0.6) }
        }
    }

    private func wav(per frequenza: Double) -> Data {
        let campioni = Int(frequenzaCampionamento * 2.0)
        var onda = [Float](repeating: 0, count: campioni)
        for n in 0..<campioni {
            let t = Double(n) / frequenzaCampionamento
            let attacco = min(1, t / 0.004)
            // fondamentale lunga + armoniche che svaniscono presto = timbro di legno/campanella
            let suono = exp(-t * 2.8) * sin(2 * .pi * frequenza * t)
                + 0.30 * exp(-t * 9) * sin(2 * .pi * frequenza * 4 * t)
                + 0.12 * exp(-t * 18) * sin(2 * .pi * frequenza * 9.2 * t)
            onda[n] = Float(0.4 * attacco * suono)
        }
        // eco morbida per dare un po' di ambiente
        for (ritardo, peso) in [(0.09, 0.28), (0.17, 0.16), (0.29, 0.09)] as [(Double, Float)] {
            let salto = Int(ritardo * frequenzaCampionamento)
            for n in stride(from: campioni - 1, through: salto, by: -1) { onda[n] += peso * onda[n - salto] }
        }

        var dati = Data()
        func aggiungi<T: FixedWidthInteger>(_ v: T) { withUnsafeBytes(of: v.littleEndian) { dati.append(contentsOf: $0) } }
        let byte = UInt32(campioni * 2)
        dati.append(contentsOf: Array("RIFF".utf8)); aggiungi(36 + byte)
        dati.append(contentsOf: Array("WAVEfmt ".utf8)); aggiungi(UInt32(16))
        aggiungi(UInt16(1)); aggiungi(UInt16(1))
        aggiungi(UInt32(frequenzaCampionamento)); aggiungi(UInt32(frequenzaCampionamento) * 2)
        aggiungi(UInt16(2)); aggiungi(UInt16(16))
        dati.append(contentsOf: Array("data".utf8)); aggiungi(byte)
        for v in onda { aggiungi(Int16(max(-1, min(1, v)) * 32767)) }
        return dati
    }
}
