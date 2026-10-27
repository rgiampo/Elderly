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

    var body: some View {
        Form {
            Section {
                HStack(spacing: 28) {
                    Avatar(utente: anteprima, dimensione: 120)
                    SelettoreFoto(foto: $foto, latoMassimo: Configurazione.latoFotoProfilo) {
                        Label(foto == nil ? "Aggiungi una foto" : "Cambia la foto", systemImage: "camera")
                            .testo(DimensioneTesto.normale)
                            .foregroundStyle(Tema.blu)
                    }
                }
            }

            Section {
                TextField("Nome", text: $nome)
                TextField("Cognome", text: $cognome)
            }

            Section("Come ci rivolgiamo a questa persona") {
                HStack(spacing: 16) {
                    ForEach(Genere.allCases) { opzione in
                        Button { genere = opzione } label: {
                            Text(opzione.nome)
                                .testo(DimensioneTesto.medio)
                                .foregroundStyle(genere == opzione ? .white : Tema.testo)
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(genere == opzione ? Tema.blu : Tema.celeste.opacity(0.5),
                                            in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(genere == opzione ? .isSelected : [])
                    }
                }
            }

            Section {
                Toggle("Conosco la data di nascita", isOn: $conosceNascita)
                if conosceNascita {
                    DatePicker("Data di nascita", selection: $dataDiNascita,
                               in: ...Date.now, displayedComponents: .date)
                } else {
                    Stepper("Età: \(eta)", value: $eta, in: 40...120)
                }
            } footer: {
                if conosceNascita, let anni = Utente.età(da: dataDiNascita) {
                    Text("Ha \(anni) anni. L'età si aggiorna da sola ogni anno.")
                }
            }

            if utente != nil {
                Section {
                    Button("Elimina questa persona", role: .destructive) { chiediEliminazione = true }
                }
            }
        }
        .testo(DimensioneTesto.normale)
        .scrollContentBackground(.hidden)
        .background(SfondoCielo())
        .navigationTitle(utente == nil ? "Nuova persona" : "Modifica")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla") { if !nome.isEmpty || foto != nil { chiediUscita = true } else { chiudi() } }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva", action: salva).disabled(nome.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .confirmationDialog("Eliminare \(nome)?", isPresented: $chiediEliminazione, titleVisibility: .visible) {
            Button("Elimina", role: .destructive, action: elimina)
        } message: {
            Text("La persona e la sua foto verranno cancellate.")
        }
        .interactiveDismissDisabled()   // toccare fuori dalla finestra non la chiude: non si perde quello che hai scritto
        .confirmationDialog("Uscire senza salvare?", isPresented: $chiediUscita, titleVisibility: .visible) {
            Button("Esci senza salvare", role: .destructive) { chiudi() }
            Button("Continua a scrivere", role: .cancel) {}
        } message: {
            Text("Quello che hai scritto andrà perso.")
        }
        .onAppear(perform: carica)
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
