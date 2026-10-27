import SwiftUI
import SwiftData
import PhotosUI

/// Aggiunge o modifica una persona. Con `utente == nil` crea una persona nuova.
struct UtenteFormView: View {
    let utente: Utente?

    @Environment(\.modelContext) private var contesto
    @Environment(\.dismiss) private var chiudi
    @AppStorage("utenteAttivo") private var attivo = ""

    @State private var nome = ""
    @State private var cognome = ""
    @State private var eta = 75
    @State private var foto: Data?
    @State private var sceltaFoto: PhotosPickerItem?
    @State private var chiediEliminazione = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 24) {
                    Avatar(utente: anteprima, dimensione: 110)
                    PhotosPicker(selection: $sceltaFoto, matching: .images) {
                        Label(foto == nil ? "Scegli una foto" : "Cambia foto", systemImage: "photo")
                    }
                }
            }

            Section {
                TextField("Nome", text: $nome)
                TextField("Cognome", text: $cognome)
                Stepper("Età: \(eta)", value: $eta, in: 40...120)
            }

            if let utente {
                Section {
                    Button("Gioca con \(utente.nome)") {
                        attivo = utente.id.uuidString
                        chiudi()
                    }
                    Button("Elimina questa persona", role: .destructive) { chiediEliminazione = true }
                }
            }
        }
        .font(.system(.title3, design: .rounded))
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
        .onChange(of: sceltaFoto) { _, nuova in
            Task { foto = await ridimensiona(nuova) }
        }
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
            let nuovo = Utente(nome: nomePulito, cognome: cognome, eta: eta, foto: foto)
            contesto.insert(nuovo)
            if attivo.isEmpty { attivo = nuovo.id.uuidString } // la prima persona è subito "in gioco"
        }
        chiudi()
    }

    private func elimina() {
        guard let utente else { return }
        if attivo == utente.id.uuidString { attivo = "" }
        contesto.delete(utente)
        chiudi()
    }

    /// Foto piccole (400 px): bastano per il cerchio e tengono leggero il database.
    private func ridimensiona(_ elemento: PhotosPickerItem?) async -> Data? {
        guard let dati = try? await elemento?.loadTransferable(type: Data.self),
              let immagine = UIImage(data: dati) else { return nil }
        let lato = min(immagine.size.width, immagine.size.height)
        let scala = 400 / lato
        let nuovaDimensione = CGSize(width: immagine.size.width * scala, height: immagine.size.height * scala)
        return UIGraphicsImageRenderer(size: nuovaDimensione).jpegData(withCompressionQuality: 0.8) { _ in
            immagine.draw(in: CGRect(origin: .zero, size: nuovaDimensione))
        }
    }
}
