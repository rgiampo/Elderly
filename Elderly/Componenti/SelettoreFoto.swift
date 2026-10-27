import SwiftUI
import PhotosUI

/// Bottone per scegliere una foto: dalla libreria oppure scattandola con la fotocamera.
/// La foto torna già ridimensionata (vedi `Immagini`). Si usa sia per le persone sia per i quiz.
struct SelettoreFoto<Etichetta: View>: View {
    @Binding var foto: Data?
    var latoMassimo: CGFloat = Configurazione.latoFotoSalvata
    @ViewBuilder let etichetta: Etichetta

    @State private var menuAperto = false
    @State private var libreriaAperta = false
    @State private var fotocameraAperta = false
    @State private var scelta: PhotosPickerItem?

    var body: some View {
        Button { menuAperto = true } label: { etichetta }
            .buttonStyle(.plain)
            .confirmationDialog("Aggiungi una foto", isPresented: $menuAperto, titleVisibility: .visible) {
                if Fotocamera.èDisponibile {
                    Button("Scatta una foto") { fotocameraAperta = true }
                }
                Button("Scegli dalla libreria") { libreriaAperta = true }
                Button("Annulla", role: .cancel) {}
            }
            .photosPicker(isPresented: $libreriaAperta, selection: $scelta, matching: .images)
            .fullScreenCover(isPresented: $fotocameraAperta) {
                Fotocamera { dati in foto = Immagini.jpegRidotto(da: dati, latoMassimo: latoMassimo) }
                    .ignoresSafeArea()
            }
            .onChange(of: scelta) { _, nuova in
                Task {
                    guard let dati = try? await nuova?.loadTransferable(type: Data.self) else { return }
                    foto = Immagini.jpegRidotto(da: dati, latoMassimo: latoMassimo)
                }
            }
    }
}
