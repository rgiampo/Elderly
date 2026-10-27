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
                // i due posti: si riempiono man mano che si tocca. Vuoti, invitano a scegliere.
                HStack(spacing: 20) {
                    ForEach(0..<Configurazione.maxGiocatori, id: \.self) { numero in
                        PostoGiocatore(numero: numero, partecipante: sessione.scelti.indices.contains(numero) ? sessione.scelti[numero] : nil)
                    }
                }
                .padding(.top, 4)

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
                            RigaUtente(utente: utente, evidenza: colore(per: utente)) { segno(per: utente) }
                                .opacity(sessione.sceltaPiena && !sessione.èScelto(utente) ? 0.4 : 1)
                                .animation(.spring(duration: 0.35, bounce: 0.35), value: posto(di: utente))
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
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .black))
                .foregroundStyle(Tema.coloreGiocatore(posto - 1))
                .frame(width: 80, height: 80)
                .background(.white, in: Circle())
                .transition(.scale.combined(with: .opacity))
        } else {
            Circle().stroke(Tema.testoSecondario.opacity(0.5), lineWidth: 5).frame(width: 80, height: 80)
        }
    }
}


/// Un posto in alto: "1° giocatore" / "2° giocatore". Vuoto è tratteggiato; pieno mostra foto e nome nel colore del giocatore.
private struct PostoGiocatore: View {
    let numero: Int
    let partecipante: Partecipante?

    var body: some View {
        HStack(spacing: 14) {
            if let partecipante {
                Avatar(utente: partecipante.utente, dimensione: 64)
                Text(partecipante.nome).testo(DimensioneTesto.normale).lineLimit(1).minimumScaleFactor(0.5)
            } else {
                Text("\(numero + 1)° giocatore").testo(DimensioneTesto.normale).lineLimit(1).minimumScaleFactor(0.5)
            }
        }
        .foregroundStyle(partecipante == nil ? Tema.testoSecondario : .white)
        .padding(.horizontal, 22).frame(maxWidth: .infinity, minHeight: 84)
        .background {
            if partecipante != nil {
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Tema.coloreGiocatore(numero))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Tema.testoSecondario.opacity(0.5), style: StrokeStyle(lineWidth: 4, dash: [12, 10]))
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.35), value: partecipante?.id)
        .accessibilityElement(children: .combine)
    }
}
