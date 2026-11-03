import SwiftUI
import SwiftData

/// In che modo si gioca il quiz scelto.
enum ModoQuiz {
    case foto, sìNo

    var titolo: String { self == .foto ? "Scegli la foto" : "Sì o no" }

    /// La frase in cima all'elenco: dice cosa fare adesso e come sarà il gioco.
    var spiegazione: String {
        self == .foto ? "Tocca un argomento per cominciare. Poi, per ogni domanda, toccherai la foto giusta."
                      : "Tocca un argomento per cominciare. Poi, per ogni foto, risponderai sì o no."
    }

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
    @State private var scelto: Quiz?
    @State private var partite = 0   // cambia a ogni "Gioca": la partita nasce nuova

    private let pronti = CatalogoQuiz.pronti()

    var body: some View {
        ZStack {
            SfondoCielo()

            VStack(alignment: .leading, spacing: 18) {
                Text(modo.spiegazione)
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testo)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 6)
                ForEach(Array((pronti + creati.map(\.comeQuiz)).enumerated()), id: \.element.id) { posizione, quiz in
                    Button { partite += 1; scelto = quiz } label: {
                        RigaQuiz(quiz: quiz) {
                            // un pulsante vero, verde come "Giochiamo!": si capisce che qui si comincia
                            Label("Gioca", systemImage: "play.fill")
                                .testo(DimensioneTesto.medio)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 30).frame(minHeight: 84)
                                .vetro(Tema.verde)
                                .fixedSize()
                        }
                    }
                    .buttonStyle(StilePremuto())
                    .accessibilityLabel("Gioca con \(quiz.titolo)")
                    .entrataAScaletta(posizione)
                }
            }
            .padding(.horizontal, 40).padding(.bottom, 40)
            .frame(maxWidth: 1100)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scorriSeServe()
        }
        // senza un'identità nuova SwiftUI riusa lo stato della partita di prima (si rientrava a metà)
        .navigationDestination(item: $scelto) { quiz in modo.vista(quiz, sessione.giocatori).id(partite) }
        .conIndietro(titolo: modo.titolo) { BarraGiocatori(giocatori: sessione.giocatori) }
    }
}

/// Un quiz in elenco: tre foto, titolo e numero di domande. A destra va quello che serve alla schermata.
struct RigaQuiz<Accessorio: View>: View {
    let quiz: Quiz
    @ViewBuilder let accessorio: Accessorio

    var body: some View {
        HStack(spacing: 24) {
            // una sola foto, in 16:9, come copertina del quiz
            FotoView(foto: quiz.fotoAnteprima.first, intera: true)
                .frame(width: 224, height: 126)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.titolo).testo(DimensioneTesto.grande)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text("\(quiz.numeroFoto) foto").testo(DimensioneTesto.medio)
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
