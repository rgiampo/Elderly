import SwiftUI
import SwiftData

/// "Crea o modifica quiz": si crea un quiz su qualsiasi argomento, si aggiungono domande a un quiz pronto
/// (se ne fa una copia tutta vostra) e si modificano o eliminano i quiz creati.
struct GestioneQuizView: View {
    @Environment(\.modelContext) private var contesto
    @Query(sort: \QuizCreato.creatoIl) private var creati: [QuizCreato]

    private let pronti = CatalogoQuiz.pronti()

    @State private var nuovo: BozzaQuiz?
    @State private var daModificare: QuizCreato?
    @State private var daEliminare: QuizCreato?
    @State private var nuovoVuoto = false

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Button { nuovoVuoto = true } label: {
                        Label("Crea un nuovo quiz", systemImage: "plus")
                            .testo(DimensioneTesto.grande)
                            .foregroundStyle(.white)
                            .lineLimit(1).minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, minHeight: 110)
                            .vetro(Tema.blu)
                    }
                    .buttonStyle(StilePremuto())

                    if !creati.isEmpty {
                        intestazione("I vostri quiz")
                        ForEach(creati) { creato in
                            schedaConAzioni(creato.comeQuiz) {
                                azione("Modifica") { daModificare = creato }
                                azione("Elimina", colore: Tema.rosso) { daEliminare = creato }
                            }
                        }
                    }

                    intestazione("Quiz pronti: aggiungi le tue domande")
                    ForEach(pronti) { quiz in
                        schedaConAzioni(quiz) {
                            azione("Aggiungi le tue domande") {
                                nuovo = BozzaQuiz(copiaDi: quiz, titolo: "\(quiz.titolo) (con le mie domande)")
                            }
                        }
                    }
                }
                .padding(.horizontal, 40).padding(.bottom, 40)
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
        }
        .conIndietro(titolo: "Crea o modifica quiz")
        .fullScreenCover(isPresented: $nuovoVuoto) { NavigationStack { EditorQuizView(quiz: nil) } }
        .fullScreenCover(item: Binding(get: { nuovo.map(Copia.init) }, set: { if $0 == nil { nuovo = nil } })) { copia in
            NavigationStack { EditorQuizView(quiz: nil, partenza: copia.bozza) }
        }
        .fullScreenCover(item: $daModificare) { quiz in NavigationStack { EditorQuizView(quiz: quiz) } }
        .confirmationDialog("Eliminare il quiz \"\(daEliminare?.titolo ?? "")\"?",
                            isPresented: Binding(get: { daEliminare != nil }, set: { if !$0 { daEliminare = nil } }),
                            titleVisibility: .visible) {
            Button("Elimina", role: .destructive) {
                if let quiz = daEliminare { contesto.delete(quiz) }
                daEliminare = nil
            }
        } message: {
            Text("Le domande e le foto del quiz verranno cancellate.")
        }
    }

    private func intestazione(_ testo: String) -> some View {
        Text(testo)
            .testo(DimensioneTesto.medio)
            .foregroundStyle(Tema.testoSecondario)
            .padding(.top, 12)
            .accessibilityAddTraits(.isHeader)
    }

    /// Il quiz sopra e, sotto, i suoi pulsanti a tutta larghezza: ogni scheda ha la stessa forma e i testi non si riducono.
    private func schedaConAzioni<Azioni: View>(_ quiz: Quiz, @ViewBuilder azioni: () -> Azioni) -> some View {
        VStack(spacing: 14) {
            RigaQuiz(quiz: quiz) { EmptyView() }
            HStack(spacing: 14) { azioni() }
        }
    }

    private func azione(_ titolo: String, colore: Color = Tema.blu, _ fai: @escaping () -> Void) -> some View {
        Button(action: fai) {
            Text(titolo)
                .testo(DimensioneTesto.normale)
                .foregroundStyle(.white)
                .lineLimit(1).minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, minHeight: MisureModulo.altezzaControllo)
                .vetro(colore)
        }
        .buttonStyle(StilePremuto())
    }

    /// Serve solo a presentare la copia in una finestra.
    private struct Copia: Identifiable {
        let id = UUID()
        let bozza: BozzaQuiz
        init(_ bozza: BozzaQuiz) { self.bozza = bozza }
    }
}
