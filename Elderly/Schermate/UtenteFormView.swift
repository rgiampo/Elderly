import SwiftUI
import SwiftData

/// Aggiunge o modifica una persona. Con `utente == nil` crea una persona nuova.
struct UtenteFormView: View {
    let utente: Utente?

    @Environment(\.modelContext) private var contesto
    @Environment(\.dismiss) private var chiudi

    @State private var nome = ""
    @State private var cognome = ""
    @State private var eta = 75
    @State private var conosceNascita = false
    @State private var dataDiNascita = Calendar.current.date(from: DateComponents(year: 1950, month: 1, day: 1)) ?? .now
    @State private var foto: Data?
    @State private var chiediEliminazione = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 24) {
                    Avatar(utente: anteprima, dimensione: 110)
                    SelettoreFoto(foto: $foto, latoMassimo: Configurazione.latoFotoProfilo) {
                        Label(foto == nil ? "Scegli una foto" : "Cambia foto", systemImage: "photo")
                    }
                }
            }

            Section {
                TextField("Nome", text: $nome)
                TextField("Cognome", text: $cognome)
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
            if utente == nil {
                ToolbarItem(placement: .cancellationAction) { Button("Annulla") { chiudi() } }
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
        .onAppear(perform: carica)
    }

    /// Una persona "di prova" solo per mostrare la foto o le iniziali mentre si scrive.
    private var anteprima: Utente {
        Utente(nome: nome, cognome: cognome, eta: eta, dataDiNascita: conosceNascita ? dataDiNascita : nil, foto: foto)
    }

    private func carica() {
        guard let utente else { return }
        nome = utente.nome; cognome = utente.cognome; eta = utente.eta; foto = utente.foto
        if let nascita = utente.dataDiNascita { conosceNascita = true; dataDiNascita = nascita }
    }

    private func salva() {
        let nomePulito = nome.trimmingCharacters(in: .whitespaces)
        if let utente {
            utente.nome = nomePulito; utente.cognome = cognome; utente.foto = foto
            utente.dataDiNascita = conosceNascita ? dataDiNascita : nil
            utente.eta = Utente.età(da: utente.dataDiNascita) ?? eta
        } else {
            let nuovo = Utente(nome: nomePulito, cognome: cognome, eta: eta,
                               dataDiNascita: conosceNascita ? dataDiNascita : nil, foto: foto)
            contesto.insert(nuovo)
        }
        chiudi()
    }

    private func elimina() {
        guard let utente else { return }
        contesto.delete(utente)
        chiudi()
    }
}
