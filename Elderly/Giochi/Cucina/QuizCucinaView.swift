import SwiftUI
import SwiftData

struct QuizCucinaView: View {
    @State private var quiz = QuizModello()
    @Environment(\.dismiss) private var chiudi

    var body: some View {
        ZStack {
            SfondoCielo()

            ScrollView {
                if quiz.finito { fine } else { domanda }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: quiz.rivelata) { _, nuova in nuova != nil }
        .sensoryFeedback(.warning, trigger: quiz.sbagliate.count) { vecchio, nuovo in nuovo > vecchio }
        .onChange(of: quiz.messaggio) { _, nuovo in
            if !nuovo.isEmpty { AccessibilityNotification.Announcement(nuovo).post() }
        }
        .onDisappear { quiz.ferma() }
    }

    private var domanda: some View {
        VStack(spacing: 28) {
            HStack(alignment: .top, spacing: 24) {
                Text(quiz.domanda.testo)
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .foregroundStyle(Tema.testo)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ChipUtente()
            }

            HStack(spacing: 28) {
                ForEach(quiz.risposte) { risposta in
                    Button { quiz.scegli(risposta) } label: {
                        SchedaRisposta(risposta: risposta, stato: stato(di: risposta))
                    }
                    .buttonStyle(StilePremuto())
                    .accessibilityLabel(risposta.testo)
                }
            }

            Text(quiz.messaggio.isEmpty ? " " : quiz.messaggio)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(Tema.testo)

            Text("Domanda \(quiz.indice + 1) di \(quiz.totale)")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(Tema.testoSecondario)

            BottoneVoce(testo: quiz.testoParlato, etichetta: "Ascolta la domanda")
        }
        .padding(40)
        .frame(maxWidth: 1100)
        .frame(maxWidth: .infinity)
    }

    private var fine: some View {
        VStack(spacing: 32) {
            Text("Bravissimo!")
                .font(.system(size: 88, weight: .heavy, design: .rounded))
            Text("Risposte giuste al primo colpo: \(quiz.punti) su \(quiz.totale)")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .multilineTextAlignment(.center)

            Button { quiz.ricomincia() } label: {
                Text("Gioca ancora").font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(.white).frame(maxWidth: 520, minHeight: 90)
            }
            .buttonStyle(.glassProminent).tint(Tema.azzurroProfondo)

            Button { chiudi() } label: {
                Text("Torna ai giochi").font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Tema.testo).frame(maxWidth: 520, minHeight: 80)
            }
            .buttonStyle(.glass)
        }
        .foregroundStyle(Tema.testo)
        .padding(60)
        .frame(maxWidth: .infinity)
        .onAppear { AccessibilityNotification.Announcement("Bravissimo! Hai finito il quiz").post() }
    }

    private func stato(di risposta: Risposta) -> SchedaRisposta.Stato {
        if quiz.rivelata == risposta.id { return .giusta }
        if quiz.sbagliate.contains(risposta.id) { return .sbagliata }
        return .normale
    }
}

/// Immagine grande e nome. Il colore non basta: la risposta giusta ha anche la spunta.
struct SchedaRisposta: View {
    enum Stato { case normale, giusta, sbagliata }
    let risposta: Risposta
    let stato: Stato

    var body: some View {
        VStack(spacing: 16) {
            Text(risposta.emoji).font(.system(size: 130))
            HStack(spacing: 10) {
                if stato == .giusta { Image(systemName: "checkmark.circle.fill") }
                Text(risposta.testo)
            }
            .font(.system(.title, design: .rounded, weight: .heavy))
            .multilineTextAlignment(.center)
        }
        .foregroundStyle(stato == .giusta ? Color.white : Tema.testo)
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding(24)
        .background(sfondo, in: RoundedRectangle(cornerRadius: 36))
        .shadow(color: Tema.testo.opacity(0.18), radius: 12, y: 6)
        .opacity(stato == .sbagliata ? 0.45 : 1)
    }

    private var sfondo: Color {
        stato == .giusta ? Color(red: 0.05, green: 0.45, blue: 0.22) : .white.opacity(0.94)
    }
}

#Preview(traits: .landscapeLeft) {
    NavigationStack { QuizCucinaView() }
        .modelContainer(for: Utente.self, inMemory: true)
}
