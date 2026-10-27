import SwiftUI
import SwiftData

/// In che modo si gioca il quiz scelto.
enum ModoQuiz {
    case foto, sìNo

    var titolo: String { self == .foto ? "Scegli la foto" : "Sì o no" }

    @ViewBuilder func vista(_ quiz: Quiz, _ giocatori: [Partecipante]) -> some View {
        switch self {
        case .foto: QuizView(quiz: quiz, giocatori: giocatori)
        case .sìNo: SiNoView(quiz: quiz, giocatori: giocatori)
        }
    }
}

/// L'elenco dei quiz con cui giocare: quelli pronti e quelli creati da voi.
struct ElencoQuizView: View {
    let modo: ModoQuiz

    @Environment(Sessione.self) private var sessione
    @Query(sort: \QuizCreato.creatoIl) private var creati: [QuizCreato]

    private let pronti = CatalogoQuiz.pronti()

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(pronti + creati.map(\.comeQuiz)) { quiz in
                        NavigationLink(destination: modo.vista(quiz, sessione.giocatori)) {
                            RigaQuiz(quiz: quiz) {
                                Image(systemName: "chevron.right").font(.system(size: 32, weight: .bold))
                            }
                        }
                        .buttonStyle(StilePremuto())
                    }
                }
                .padding(.horizontal, 40).padding(.bottom, 40)
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
        }
        .conIndietro(titolo: modo.titolo) { BarraGiocatori(giocatori: sessione.giocatori) }
    }
}

/// Un quiz in elenco: tre foto, titolo e numero di domande. A destra va quello che serve alla schermata.
struct RigaQuiz<Accessorio: View>: View {
    let quiz: Quiz
    @ViewBuilder let accessorio: Accessorio

    var body: some View {
        HStack(spacing: 24) {
            HStack(spacing: -28) {
                ForEach(Array(quiz.fotoAnteprima.enumerated()), id: \.offset) { _, foto in
                    FotoView(foto: foto)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
            }
            .frame(minWidth: 160, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.titolo).testo(DimensioneTesto.grande)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text("\(quiz.domande.count) domande").testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testoSecondario)
            }
            Spacer(minLength: 0)
            accessorio
        }
        .foregroundStyle(Tema.testo)
        .padding(20)
        .frame(minHeight: 140)
        .scheda()
        .accessibilityElement(children: .combine)
    }
}

extension QuizCreato: Identifiable {}
