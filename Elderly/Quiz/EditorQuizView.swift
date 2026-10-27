import SwiftUI
import SwiftData

/// Crea o modifica un quiz: titolo, domande e, per ogni domanda, due foto con il loro nome.
struct EditorQuizView: View {
    let quiz: QuizCreato?   // nil = quiz nuovo
    var partenza: BozzaQuiz?  // per un quiz nuovo che parte da una copia di un quiz pronto

    @Environment(\.modelContext) private var contesto
    @Environment(\.dismiss) private var chiudi
    @State private var bozza = BozzaQuiz()
    @State private var chiediUscita = false

    var body: some View {
        ModuloView(titolo: quiz == nil ? "Nuovo quiz" : "Modifica quiz",
                   annulla: { if !bozza.titolo.isEmpty && quiz == nil { chiediUscita = true } else { chiudi() } },
                   salva: salva, puòSalvare: bozza.problema == nil) {
            CampoTesto(titolo: "Titolo del quiz", testo: $bozza.titolo, esempio: "Per esempio: Frutta e verdura")

            ForEach(bozza.domande.indices, id: \.self) { posizione in
                SchedaDomanda(numero: posizione + 1,
                              domanda: $bozza.domande[posizione],
                              puòEliminare: bozza.domande.count > 1,
                              elimina: { bozza.domande.remove(at: posizione) })
            }

            Button { bozza.domande.append(BozzaDomanda()) } label: {
                Label("Aggiungi una domanda", systemImage: "plus")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, minHeight: MisureModulo.altezzaControllo)
                    .vetro(.white.opacity(0.78))
            }
            .buttonStyle(StilePremuto())

            // dice cosa manca per poter salvare
            if let problema = bozza.problema {
                Text(problema)
                    .testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
                    .padding(.top, 4)
            }
        }
        .interactiveDismissDisabled()   // toccare fuori dalla finestra non la chiude: non si perde il quiz
        .confirmationDialog("Uscire senza salvare?", isPresented: $chiediUscita, titleVisibility: .visible) {
            Button("Esci senza salvare", role: .destructive) { chiudi() }
            Button("Continua a scrivere", role: .cancel) {}
        } message: {
            Text("Quello che hai scritto andrà perso.")
        }
        .onAppear {
            if let quiz { bozza = BozzaQuiz(quiz) } else if let partenza { bozza = partenza }
        }
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

/// Una domanda: il testo e le sue due risposte, ognuna con la foto e il nome.
private struct SchedaDomanda: View {
    let numero: Int
    @Binding var domanda: BozzaDomanda
    let puòEliminare: Bool
    let elimina: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Domanda \(numero)").testo(DimensioneTesto.grande).foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Spacer()
                if puòEliminare {
                    Button(action: elimina) {
                        Text("Elimina")
                            .testo(DimensioneTesto.normale)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .frame(minHeight: 64)
                            .vetro(Tema.rosso)
                    }
                    .buttonStyle(StilePremuto())
                }
            }

            CampoTesto(titolo: "Domanda", testo: $domanda.testo, esempio: "Per esempio: Quale è il gatto?")

            ForEach(domanda.risposte.indices, id: \.self) { posizione in
                CampiRisposta(numero: posizione + 1,
                              risposta: $domanda.risposte[posizione],
                               èGiusta: domanda.indiceGiusta == posizione,
                               scegliGiusta: { domanda.indiceGiusta = posizione })
            }
        }
        .padding(28)
        .vetro(Tema.celesteChiaro, in: RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous))   // così i campi bianchi si vedono
    }
}

/// Una risposta: la foto (si tocca per scegliere o scattare), il nome e il pulsante "È quella giusta".
private struct CampiRisposta: View {
    let numero: Int
    @Binding var risposta: BozzaRisposta
    let èGiusta: Bool
    let scegliGiusta: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            SelettoreFoto(foto: $risposta.foto) {
                ZStack(alignment: .bottom) {
                    FotoView(foto: risposta.foto.map(FotoQuiz.dati))
                    Text(risposta.foto == nil ? "Aggiungi la foto" : "Cambia la foto")
                        .testo(DimensioneTesto.normale)
                        .foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Tema.testo.opacity(0.78))
                }
                .frame(width: 300, height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 14) {
                CampoTesto(titolo: "Nome della risposta \(numero)", testo: $risposta.testo, esempio: "Per esempio: Gatto")
                Button(action: scegliGiusta) {
                    Text(èGiusta ? "È la risposta giusta" : "Segna come giusta")
                        .testo(DimensioneTesto.normale)
                        .foregroundStyle(èGiusta ? .white : Tema.testo)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .vetro(èGiusta ? Tema.verde : .white.opacity(0.78), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(StilePremuto())
                .accessibilityAddTraits(èGiusta ? .isSelected : [])
            }
        }
    }
}
