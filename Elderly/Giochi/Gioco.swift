import SwiftUI

/// L'elenco dei giochi. Per aggiungerne uno: un nuovo caso qui, e la sua schermata.
enum Gioco: CaseIterable, Identifiable {
    case forme, coppie, cosaManca, proverbi, quiz, sìNo

    var id: Self { self }

    var categoria: Categoria {
        switch self {
        case .forme, .coppie, .cosaManca, .proverbi: .memoria
        case .quiz, .sìNo: .foto
        }
    }

    var titolo: String {
        switch self {
        case .forme: "Suona le forme"
        case .coppie: "Trova le coppie"
        case .cosaManca: "Cosa manca?"
        case .proverbi: "Proverbi"
        case .quiz: "Scegli la foto"
        case .sìNo: "Sì o no"
        }
    }

    var descrizione: String {
        switch self {
        case .forme: "Ripeti la melodia"
        case .coppie: "Trova le foto uguali"
        case .cosaManca: "Quale foto è sparita?"
        case .proverbi: "Completa il proverbio"
        case .quiz: "Trova la foto giusta"
        case .sìNo: "Rispondi con una forma"
        }
    }

    @ViewBuilder var destinazione: some View {
        switch self {
        case .forme: FormeImpostazioniView()
        case .coppie: CoppieImpostazioniView()
        case .cosaManca: CosaMancaImpostazioniView()
        case .proverbi: ProverbiImpostazioniView()
        case .quiz: ElencoQuizView(modo: .foto)
        case .sìNo: ElencoQuizView(modo: .sìNo)
        }
    }

    /// L'immagine che dà l'idea del gioco. Riempie tutta la parte alta della scheda, bordo a bordo.
    @ViewBuilder var anteprima: some View {
        switch self {
        case .forme:
            HStack(spacing: 14) {
                ForEach([Forma.cerchio, .quadrato, .triangolo, .stella]) { forma in
                    forma.sagoma.fill(forma.colore).aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(28)
            .sfondoAnteprima()
        case .coppie:
            IllustrazioneCoppia(conCarteCoperte: false)
                .padding(.horizontal, 32).padding(.vertical, 20)
                .sfondoAnteprima()
        case .cosaManca:
            HStack(spacing: 14) {
                scheda(.risorsa("foto_gatto"))
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Tema.blu)
                    .aspectRatio(1.3, contentMode: .fit)
                    .overlay(Text("?").testo(DimensioneTesto.grande).foregroundStyle(.white))
                scheda(.risorsa("foto_pizza"))
            }
            .padding(24)
            .sfondoAnteprima()
        case .proverbi:
            VStack(spacing: 14) {
                Text("Chi dorme …").testo(DimensioneTesto.medio).foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text("non piglia pesci").testo(DimensioneTesto.normale).foregroundStyle(.white)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .padding(.horizontal, 24).frame(minHeight: 60)
                    .background(Tema.verde, in: Capsule())
            }
            .padding(24)
            .sfondoAnteprima()
        case .quiz:
            // una sola foto, grande
            metà(.risorsa("foto_gatto"))
        case .sìNo:
            // una sola immagine: a sinistra il cerchio verde (sì), a destra il triangolo rosso (no)
            HStack(spacing: 0) {
                Tema.verde.overlay(Circle().fill(.white).aspectRatio(1, contentMode: .fit).padding(40))
                Tema.rosso.overlay(SagomaTriangolo().fill(.white).aspectRatio(1, contentMode: .fit).padding(40))
            }
        }
    }

    private func metà(_ foto: FotoQuiz) -> some View {
        Color.clear.overlay { FotoView(foto: foto, intera: false) }.clipped()
    }

    private func scheda(_ foto: FotoQuiz) -> some View {
        FotoView(foto: foto, intera: false)
            .aspectRatio(1.3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private extension View {
    /// Fondo azzurro chiaro per le anteprime fatte di disegni (le foto invece riempiono tutto).
    func sfondoAnteprima() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity).background(Tema.celeste.opacity(0.35))
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
