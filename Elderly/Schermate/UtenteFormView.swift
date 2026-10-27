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
                Stepper("Età: \(eta)", value: $eta, in: 40...120)
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
        Utente(nome: nome, cognome: cognome, eta: eta, foto: foto)
    }

    private func carica() {
        guard let utente else { return }
        nome = utente.nome; cognome = utente.cognome; eta = utente.eta; foto = utente.foto
    }

    private func salva() {
        let nomePulito = nome.trimmingCharacters(in: .whitespaces)
        if let utente {
            utente.nome = nomePulito; utente.cognome = cognome; utente.eta = eta; utente.foto = foto
        } else {
            contesto.insert(Utente(nome: nomePulito, cognome: cognome, eta: eta, foto: foto))
        }
        chiudi()
    }

    private func elimina() {
        guard let utente else { return }
        contesto.delete(utente)
        chiudi()
    }
}
