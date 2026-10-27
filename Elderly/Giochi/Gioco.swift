import SwiftUI

/// L'elenco dei giochi. Per aggiungerne uno: un nuovo caso qui, e la sua schermata.
enum Gioco: CaseIterable, Identifiable {
    case forme, coppie, quiz, sìNo

    var id: Self { self }

    enum Categoria: String, CaseIterable {
        case memoria = "Quiz di memoria"
        case foto = "Quiz con le foto"
    }

    var categoria: Categoria {
        switch self {
        case .forme, .coppie: .memoria
        case .quiz, .sìNo: .foto
        }
    }

    var titolo: String {
        switch self {
        case .forme: "Suona le forme"
        case .coppie: "Trova le coppie"
        case .quiz: "Scegli la foto"
        case .sìNo: "Sì o no"
        }
    }

    var descrizione: String {
        switch self {
        case .forme: "Ripeti la melodia"
        case .coppie: "Trova le foto uguali"
        case .quiz: "Trova la foto giusta"
        case .sìNo: "Rispondi con una forma"
        }
    }

    @ViewBuilder var destinazione: some View {
        switch self {
        case .forme: FormeImpostazioniView()
        case .coppie: CoppieImpostazioniView()
        case .quiz: ElencoQuizView(modo: .foto)
        case .sìNo: ElencoQuizView(modo: .sìNo)
        }
    }

    /// L'immagine che dà l'idea del gioco.
    @ViewBuilder var anteprima: some View {
        switch self {
        case .forme:
            HStack(spacing: 14) {
                ForEach([Forma.cerchio, .quadrato, .triangolo, .stella]) { forma in
                    forma.sagoma.fill(forma.colore).aspectRatio(1, contentMode: .fit)
                }
            }.padding(18)
        case .coppie:
            HStack(spacing: 12) {
                carta(.risorsa("foto_marinara"))
                carta(nil)
                carta(.risorsa("foto_marinara"))
            }.padding(14)
        case .quiz:
            HStack(spacing: 12) {
                FotoView(foto: .risorsa("foto_calzone")).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                FotoView(foto: .risorsa("foto_polpette")).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }.padding(14)
        case .sìNo:
            HStack(spacing: 40) {
                Circle().fill(Tema.verde).aspectRatio(1, contentMode: .fit)
                SagomaTriangolo().fill(Tema.rosso).aspectRatio(1, contentMode: .fit)
            }.padding(18)
        }
    }

    @ViewBuilder private func carta(_ foto: FotoQuiz?) -> some View {
        if let foto {
            FotoView(foto: foto).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Tema.blu)
                .overlay(Text("?").testo(DimensioneTesto.grande).foregroundStyle(.white))
        }
    }
}
