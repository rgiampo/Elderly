import SwiftUI
import SwiftData

/// L'elenco dei quiz: quelli pronti e quelli creati. Da qui si gioca e si crea.
struct ElencoQuizView: View {
    @Environment(Sessione.self) private var sessione
    @Environment(\.modelContext) private var contesto
    @Query(sort: \QuizCreato.creatoIl) private var creati: [QuizCreato]

    private let pronti = CatalogoQuiz.pronti()
    @State private var bozzaInModifica: QuizCreato?
    @State private var nuovoQuiz = false
    @State private var daEliminare: QuizCreato?

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Quiz con le foto")
                            .testo(DimensioneTesto.titolo, .heavy)
                            .foregroundStyle(Tema.testo)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        BarraGiocatori(giocatori: sessione.giocatori)
                    }

                    ForEach(pronti) { quiz in
                        RigaQuiz(quiz: quiz, giocatori: sessione.giocatori, azioni: nil)
                    }

                    if !creati.isEmpty {
                        Text("I vostri quiz")
                            .testo(DimensioneTesto.medio, .bold)
                            .foregroundStyle(Tema.testoSecondario)
                            .padding(.top, 12)
                    }
                    ForEach(creati) { creato in
                        RigaQuiz(quiz: creato.comeQuiz, giocatori: sessione.giocatori,
                                 azioni: Azioni(modifica: { bozzaInModifica = creato }, elimina: { daEliminare = creato }))
                    }

                    Button { nuovoQuiz = true } label: {
                        Label("Crea un quiz", systemImage: "plus")
                            .testo(DimensioneTesto.medio, .heavy)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 84)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Tema.azzurroProfondo)
                    .padding(.top, 12)
                }
                .padding(40)
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $nuovoQuiz) { NavigationStack { EditorQuizView(quiz: nil) } }
        .sheet(item: $bozzaInModifica) { quiz in NavigationStack { EditorQuizView(quiz: quiz) } }
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
}

/// Cosa si può fare con un quiz creato da noi.
private struct Azioni {
    let modifica: () -> Void
    let elimina: () -> Void
}

private struct RigaQuiz: View {
    let quiz: Quiz
    let giocatori: [Partecipante]
    let azioni: Azioni?

    var body: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: QuizView(quiz: quiz, giocatori: giocatori)) {
                HStack(spacing: 24) {
                    HStack(spacing: -28) {
                        ForEach(Array(quiz.fotoAnteprima.enumerated()), id: \.offset) { _, foto in
                            FotoView(foto: foto)
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white, lineWidth: 4))
                        }
                    }
                    .frame(minWidth: 150, alignment: .leading)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(quiz.titolo).testo(DimensioneTesto.grande, .heavy)
                        Text("\(quiz.domande.count) domande").testo(DimensioneTesto.normale)
                            .foregroundStyle(Tema.testoSecondario)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 32, weight: .bold))
                }
                .foregroundStyle(Tema.testo)
                .padding(24)
                .frame(minHeight: 150)
                .scheda(raggio: 36)
            }
            .buttonStyle(StilePremuto())

            if let azioni {
                Menu {
                    Button("Modifica", systemImage: "pencil", action: azioni.modifica)
                    Button("Elimina", systemImage: "trash", role: .destructive, action: azioni.elimina)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 30, weight: .bold))
                        .frame(width: 72, height: 72)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Modifica o elimina il quiz \(quiz.titolo)")
            }
        }
    }
}

extension QuizCreato: Identifiable {}
