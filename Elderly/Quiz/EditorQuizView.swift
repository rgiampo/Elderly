import SwiftUI
import SwiftData

/// Crea o modifica un quiz: titolo, domande e, per ogni risposta, una foto e il suo nome.
struct EditorQuizView: View {
    let quiz: QuizCreato?   // nil = quiz nuovo

    @Environment(\.modelContext) private var contesto
    @Environment(\.dismiss) private var chiudi
    @State private var bozza = BozzaQuiz()

    var body: some View {
        Form {
            Section("Titolo del quiz") {
                TextField("Per esempio: Frutta e verdura", text: $bozza.titolo)
            }

            ForEach(bozza.domande.indices, id: \.self) { posizione in
                SezioneDomanda(numero: posizione + 1,
                               domanda: $bozza.domande[posizione],
                               puòEliminare: bozza.domande.count > 1,
                               elimina: { bozza.domande.remove(at: posizione) })
            }

            Section {
                Button("Aggiungi una domanda", systemImage: "plus") { bozza.domande.append(BozzaDomanda()) }
            }

            if let problema = bozza.problema {
                Section { Label(problema, systemImage: "info.circle").foregroundStyle(Tema.testoSecondario) }
            }
        }
        .font(.system(.title3, design: .rounded))
        .scrollContentBackground(.hidden)
        .background(SfondoCielo())
        .navigationTitle(quiz == nil ? "Nuovo quiz" : "Modifica quiz")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Annulla") { chiudi() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva", action: salva).disabled(bozza.problema != nil)
            }
        }
        .onAppear { if let quiz { bozza = BozzaQuiz(quiz) } }
    }

    private func salva() {
        let titolo = bozza.titolo.trimmingCharacters(in: .whitespaces)
        if let quiz {
            quiz.domande.forEach(contesto.delete)
            quiz.titolo = titolo
            quiz.domande = bozza.comeDomande()
        } else {
            let nuovo = QuizCreato(titolo: titolo)
            nuovo.domande = bozza.comeDomande()
            contesto.insert(nuovo)
        }
        chiudi()
    }
}

/// Una domanda con le sue risposte.
private struct SezioneDomanda: View {
    let numero: Int
    @Binding var domanda: BozzaDomanda
    let puòEliminare: Bool
    let elimina: () -> Void

    var body: some View {
        Section("Domanda \(numero)") {
            TextField("Scrivi la domanda", text: $domanda.testo, axis: .vertical)

            ForEach(domanda.risposte.indices, id: \.self) { posizione in
                RigaRisposta(risposta: $domanda.risposte[posizione],
                             èGiusta: domanda.indiceGiusta == posizione,
                             scegliGiusta: { domanda.indiceGiusta = posizione },
                             rimuovi: domanda.risposte.count > Configurazione.risposteMinime ? { togli(posizione) } : nil)
            }

            if domanda.risposte.count < Configurazione.risposteMassime {
                Button("Aggiungi una risposta", systemImage: "plus") { domanda.risposte.append(BozzaRisposta()) }
            }
            if puòEliminare {
                Button("Elimina questa domanda", systemImage: "trash", role: .destructive, action: elimina)
            }
        }
    }

    private func togli(_ posizione: Int) {
        domanda.risposte.remove(at: posizione)
        if domanda.indiceGiusta >= domanda.risposte.count { domanda.indiceGiusta = 0 }
        else if domanda.indiceGiusta > posizione { domanda.indiceGiusta -= 1 }
    }
}

/// Una risposta: foto, nome e il pulsante "è quella giusta".
private struct RigaRisposta: View {
    @Binding var risposta: BozzaRisposta
    let èGiusta: Bool
    let scegliGiusta: () -> Void
    let rimuovi: (() -> Void)?

    var body: some View {
        HStack(spacing: 18) {
            SelettoreFoto(foto: $risposta.foto) {
                FotoView(foto: risposta.foto.map(FotoQuiz.dati))
                    .frame(width: 120, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill").padding(6).background(.white, in: Circle()).padding(4)
                    }
            }
            TextField("Nome della risposta", text: $risposta.testo)

            Button(action: scegliGiusta) {
                Label(èGiusta ? "Giusta" : "Giusta?", systemImage: èGiusta ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(èGiusta ? Color.green : Tema.testoSecondario)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(èGiusta ? "Questa è la risposta giusta" : "Segna come risposta giusta")

            if let rimuovi {
                Button(role: .destructive, action: rimuovi) { Image(systemName: "minus.circle") }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Togli questa risposta")
            }
        }
    }
}
