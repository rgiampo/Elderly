import SwiftUI
import SwiftData

/// "Chi gioca?": una lista come quella degli Utenti. Si toccano una o due persone (il numero dice chi comincia).
/// Senza scelta si gioca senza nome.
struct ChiGiocaView: View {
    @Environment(Sessione.self) private var sessione
    @Query(sort: \Utente.nome) private var utenti: [Utente]

    var body: some View {
        ZStack {
            SfondoCielo()

            VStack(spacing: 24) {
                Text("Scegli una o due persone, oppure vai avanti per giocare senza nome")
                    .testo(DimensioneTesto.normale)
                    .foregroundStyle(Tema.testoSecondario)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if utenti.isEmpty {
                    Text("Non ci sono ancora persone: le aggiungi nella sezione Utenti.")
                        .testo(DimensioneTesto.medio)
                        .foregroundStyle(Tema.testo)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 24)
                    Spacer(minLength: 0)
                } else {
                    ListaAlfabetica(utenti: utenti) { utente in
                        Button { sessione.alterna(utente) } label: {
                            RigaUtente(utente: utente) { segno(per: utente) }
                                .overlay(RoundedRectangle(cornerRadius: Tema.raggio, style: .continuous).stroke(colore(per: utente) ?? .clear, lineWidth: 6))
                                .opacity(sessione.sceltaPiena && !sessione.èScelto(utente) ? 0.4 : 1)
                                
                        }
                        .buttonStyle(StilePremuto())
                        .accessibilityValue(posto(di: utente).map { "Scelto, numero \($0)" } ?? "Non scelto")
                        .accessibilityHint(sessione.sceltaPiena && !sessione.èScelto(utente)
                                           ? "Sono già state scelte due persone" : "Tocca per scegliere")
                    }
                }

                NavigationLink(destination: GiochiView()) {
                    PulsantePrincipale(titolo: "Avanti", altezza: 110)
                }
                .buttonStyle(StilePremuto())
            }
            .padding(.horizontal, 40).padding(.bottom, 32)
            .frame(maxWidth: 1100)
        }
        .conIndietro(titolo: "Chi gioca?")
    }

    /// 1 o 2 se la persona è scelta (l'ordine è l'ordine dei turni), altrimenti nil.
    private func posto(di utente: Utente) -> Int? {
        sessione.scelti.firstIndex { $0.id == utente.id }.map { $0 + 1 }
    }

    private func colore(per utente: Utente) -> Color? { posto(di: utente).map { Tema.coloreGiocatore($0 - 1) } }

    @ViewBuilder private func segno(per utente: Utente) -> some View {
        if let posto = posto(di: utente) {
            Text("\(posto)")
                .testo(DimensioneTesto.grande)
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(Tema.coloreGiocatore(posto - 1), in: Circle())
        } else {
            Circle().stroke(Tema.testoSecondario.opacity(0.5), lineWidth: 5).frame(width: 80, height: 80)
        }
    }
}
