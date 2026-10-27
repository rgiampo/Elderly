import SwiftUI

/// L'elenco dei giochi. Per aggiungerne uno: un nuovo caso qui, e la sua schermata.
enum Gioco: CaseIterable, Identifiable {
    case forme, coppie, quiz, sìNo

    var id: Self { self }

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
            }.padding(22)
        case .coppie:
            HStack(spacing: 12) {
                carta(.risorsa("foto_marinara"))
                carta(nil)
                carta(.risorsa("foto_marinara"))
            }.padding(16)
        case .quiz:
            HStack(spacing: 12) {
                carta(.risorsa("foto_gatto"))
                carta(.risorsa("foto_cane"))
            }.padding(16)
        case .sìNo:
            HStack(spacing: 40) {
                Circle().fill(Tema.verde).aspectRatio(1, contentMode: .fit)
                SagomaTriangolo().fill(Tema.rosso).aspectRatio(1, contentMode: .fit)
            }.padding(22)
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

/// Le due famiglie di giochi, più la sezione per creare i quiz. Sono la prima scelta, una sola cosa alla volta.
enum Categoria: CaseIterable, Identifiable {
    case memoria, foto, crea

    var id: Self { self }

    var titolo: String {
        switch self {
        case .memoria: "Giochi di memoria"
        case .foto: "Quiz con le foto"
        case .crea: "Crea o modifica quiz"
        }
    }

    var giochi: [Gioco] { Gioco.allCases.filter { $0.categoria == self } }

    /// Tre immagini grandi che fanno capire di cosa si tratta, senza leggere.
    @ViewBuilder var anteprima: some View {
        switch self {
        case .memoria:
            HStack(spacing: 14) {
                Circle().fill(Forma.cerchio.colore).aspectRatio(1, contentMode: .fit)
                Rectangle().fill(Forma.quadrato.colore).aspectRatio(1, contentMode: .fit)
                SagomaTriangolo().fill(Forma.triangolo.colore).aspectRatio(1, contentMode: .fit)
            }
        case .foto:
            HStack(spacing: 14) {
                FotoView(foto: .risorsa("foto_marinara")).clipShape(Circle())
                FotoView(foto: .risorsa("foto_gatto")).clipShape(Circle())
                FotoView(foto: .risorsa("foto_arancia")).clipShape(Circle())
            }
        case .crea:
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 120))
                .foregroundStyle(Tema.blu)
        }
    }
}
