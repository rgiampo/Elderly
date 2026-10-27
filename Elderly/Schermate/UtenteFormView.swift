import SwiftUI
import SwiftData

/// Aggiunge o modifica una persona. Con `utente == nil` crea una persona nuova.
struct UtenteFormView: View {
    let utente: Utente?

    @Environment(\.modelContext) private var contesto
    @Environment(\.dismiss) private var chiudi

    @State private var nome = ""
    @State private var cognome = ""
    @State private var genere: Genere?
    @State private var eta = 75
    @State private var conosceNascita = false
    @State private var dataDiNascita = Calendar.current.date(from: DateComponents(year: 1950, month: 1, day: 1)) ?? .now
    @State private var foto: Data?
    @State private var chiediEliminazione = false
    @State private var chiediUscita = false

    private var haScritto: Bool { !nome.isEmpty || !cognome.isEmpty || foto != nil }
    private var puòSalvare: Bool { !nome.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ModuloView(titolo: utente == nil ? "Nuova persona" : "Modifica",
                   annulla: { if haScritto && utente == nil { chiediUscita = true } else { chiudi() } },
                   salva: salva, puòSalvare: puòSalvare) {
            sezioneFoto
            CampoTesto(titolo: "Nome", testo: $nome, esempio: "Per esempio: Pino")
            CampoTesto(titolo: "Cognome", testo: $cognome, esempio: "Per esempio: Mauro")

            SezioneModulo(titolo: "Come ci rivolgiamo a questa persona") {
                SceltaGrande(opzioni: [(Genere.maschio, "Uomo"), (Genere.femmina, "Donna")], scelta: $genere)
            }

            SezioneModulo(titolo: "Data di nascita") {
                SceltaGrande(opzioni: [(true, "La conosco"), (false, "Non la so")],
                             scelta: Binding(get: { conosceNascita }, set: { conosceNascita = $0 ?? false }))
                if conosceNascita { sceltaData } else { ContatoreGrande(valore: $eta, intervallo: 40...120) }
            }

            if utente != nil {
                Button { chiediEliminazione = true } label: {
                    Text("Elimina questa persona")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: MisureModulo.altezzaControllo)
                        .vetro(Tema.rosso)
                }
                .buttonStyle(StilePremuto())
                .padding(.top, 20)
            }
        }
        .interactiveDismissDisabled()   // toccare fuori dalla finestra non la chiude: non si perde quello che hai scritto
        .confirmationDialog("Uscire senza salvare?", isPresented: $chiediUscita, titleVisibility: .visible) {
            Button("Esci senza salvare", role: .destructive) { chiudi() }
            Button("Continua a scrivere", role: .cancel) {}
        } message: {
            Text("Quello che hai scritto andrà perso.")
        }
        .confirmationDialog("Eliminare \(nome)?", isPresented: $chiediEliminazione, titleVisibility: .visible) {
            Button("Elimina", role: .destructive, action: elimina)
        } message: {
            Text("La persona e la sua foto verranno cancellate.")
        }
        .onAppear(perform: carica)
    }

    private var sezioneFoto: some View {
        HStack(spacing: 28) {
            Avatar(utente: anteprima, dimensione: 130)
            SelettoreFoto(foto: $foto, latoMassimo: Configurazione.latoFotoProfilo) {
                Text(foto == nil ? "Aggiungi una foto" : "Cambia la foto")
                    .testo(DimensioneTesto.medio)
                    .foregroundStyle(Tema.testo)
                    .lineLimit(1).minimumScaleFactor(0.5)
                    .padding(.horizontal, 32)
                    .frame(minHeight: MisureModulo.altezzaControllo)
                    .vetro(.white.opacity(0.78))
            }
            Spacer(minLength: 0)
        }
    }

    private var sceltaData: some View {
        VStack(spacing: 10) {
            DatePicker("Data di nascita", selection: $dataDiNascita, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "it_IT"))
                .frame(maxWidth: .infinity)
                .scheda(raggio: 28)
            if let anni = Utente.età(da: dataDiNascita) {
                Text("Ha \(anni) anni. L'età si aggiorna da sola ogni anno.")
                    .testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
            }
        }
    }

    /// Una persona "di prova" solo per mostrare la foto o le iniziali mentre si scrive.
    private var anteprima: Utente {
        Utente(nome: nome, cognome: cognome, eta: eta, genere: genere, foto: foto)
    }

    private func carica() {
        guard let utente else { return }
        nome = utente.nome; cognome = utente.cognome; genere = utente.genere; eta = utente.eta; foto = utente.foto
        if let nascita = utente.dataDiNascita { conosceNascita = true; dataDiNascita = nascita }
    }

    private func salva() {
        let nomePulito = nome.trimmingCharacters(in: .whitespaces)
        let nascita = conosceNascita ? dataDiNascita : nil
        if let utente {
            utente.nome = nomePulito; utente.cognome = cognome; utente.genere = genere; utente.foto = foto
            utente.dataDiNascita = nascita
            utente.eta = Utente.età(da: nascita) ?? eta
        } else {
            contesto.insert(Utente(nome: nomePulito, cognome: cognome, eta: eta, dataDiNascita: nascita, genere: genere, foto: foto))
        }
        chiudi()
    }

    private func elimina() {
        guard let utente else { return }
        contesto.delete(utente)
        chiudi()
    }
}
