import SwiftUI

/// Le forme del gioco: ognuna ha un colore e una nota (do, re, mi, fa, sol),
/// così si possono suonare melodie conosciute.
enum Forma: CaseIterable, Identifiable {
    case cerchio, quadrato, triangolo, stella, cuore, rombo, esagono, pentagono, ottagono, croce, ovale, semicerchio

    var id: Self { self }

    /// Nome letto da VoiceOver: forma e colore, così non si dipende dal solo colore.
    var nome: String {
        switch self {
        case .cerchio: "Cerchio rosso"
        case .quadrato: "Quadrato blu"
        case .triangolo: "Triangolo giallo"
        case .stella: "Stella verde"
        case .cuore: "Cuore rosa"
        case .rombo: "Rombo arancione"
        case .esagono: "Esagono viola"
        case .pentagono: "Pentagono azzurro"
        case .ottagono: "Ottagono marrone"
        case .croce: "Croce rosa scuro"
        case .ovale: "Ovale verde chiaro"
        case .semicerchio: "Semicerchio blu scuro"
        }
    }

    var colore: Color {
        switch self {
        case .cerchio: Color(red: 0.93, green: 0.30, blue: 0.30)
        case .quadrato: Color(red: 0.25, green: 0.50, blue: 0.95)
        case .triangolo: Color(red: 0.98, green: 0.75, blue: 0.15)
        case .stella: Color(red: 0.25, green: 0.72, blue: 0.40)
        case .cuore: Color(red: 0.95, green: 0.45, blue: 0.70)
        case .rombo: Color(red: 0.98, green: 0.55, blue: 0.15)
        case .esagono: Color(red: 0.55, green: 0.38, blue: 0.85)
        case .pentagono: Color(red: 0.10, green: 0.70, blue: 0.78)
        case .ottagono: Color(red: 0.62, green: 0.40, blue: 0.25)
        case .croce: Color(red: 0.80, green: 0.20, blue: 0.50)
        case .ovale: Color(red: 0.55, green: 0.80, blue: 0.20)
        case .semicerchio: Color(red: 0.15, green: 0.30, blue: 0.70)
        }
    }

    /// Le dodici note della scala di do (do re mi fa sol la si do re mi fa sol): le prime cinque bastano per le melodie più semplici.
    var frequenza: Double {
        switch self {
        case .cerchio: 523.25
        case .quadrato: 587.33
        case .triangolo: 659.25
        case .stella: 698.46
        case .cuore: 783.99
        case .rombo: 880.00
        case .esagono: 987.77
        case .pentagono: 1046.50
        case .ottagono: 1174.66
        case .croce: 1318.51
        case .ovale: 1396.91
        case .semicerchio: 1567.98
        }
    }

    var sagoma: AnyShape {
        switch self {
        case .cerchio: AnyShape(Circle())
        case .quadrato: AnyShape(Rectangle())
        case .triangolo: AnyShape(SagomaTriangolo())
        case .stella: AnyShape(SagomaStella())
        case .cuore: AnyShape(SagomaCuore())
        case .rombo: AnyShape(SagomaPoligono(lati: 4))
        case .esagono: AnyShape(SagomaPoligono(lati: 6))
        case .pentagono: AnyShape(SagomaPoligono(lati: 5))
        case .ottagono: AnyShape(SagomaPoligono(lati: 8))
        case .croce: AnyShape(SagomaCroce())
        case .ovale: AnyShape(Ellipse().scale(x: 0.62, y: 1))
        case .semicerchio: AnyShape(SagomaSemicerchio())
        }
    }
}

struct SagomaCroce: Shape {
    func path(in rect: CGRect) -> Path {
        let t = rect.width / 3
        var p = Path()
        p.addRect(CGRect(x: rect.minX + t, y: rect.minY, width: t, height: rect.height))
        p.addRect(CGRect(x: rect.minX, y: rect.minY + t, width: rect.width, height: t))
        return p
    }
}

/// Mezzo cerchio con la parte piatta in basso, centrato nel riquadro.
struct SagomaSemicerchio: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = rect.width / 2
        let base = rect.midY + r / 2
        p.move(to: CGPoint(x: rect.minX, y: base))
        p.addArc(center: CGPoint(x: rect.midX, y: base), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.closeSubpath()
        return p
    }
}

/// Poligono regolare con la punta in alto (4 lati = rombo).
struct SagomaPoligono: Shape {
    let lati: Int
    func path(in rect: CGRect) -> Path {
        let raggio = min(rect.width, rect.height) / 2
        var p = Path()
        for i in 0..<lati {
            let angolo = Double(i) * 2 * .pi / Double(lati) - .pi / 2
            let punto = CGPoint(x: rect.midX + raggio * cos(angolo), y: rect.midY + raggio * sin(angolo))
            i == 0 ? p.move(to: punto) : p.addLine(to: punto)
        }
        p.closeSubpath()
        return p
    }
}

struct SagomaTriangolo: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct SagomaStella: Shape {
    func path(in rect: CGRect) -> Path {
        let centro = CGPoint(x: rect.midX, y: rect.midY)
        let raggioEsterno = min(rect.width, rect.height) / 2
        let raggioInterno = raggioEsterno * 0.5
        var p = Path()
        for i in 0..<10 {
            let raggio = i.isMultiple(of: 2) ? raggioEsterno : raggioInterno
            let angolo = Double(i) * .pi / 5 - .pi / 2
            let punto = CGPoint(x: centro.x + raggio * cos(angolo), y: centro.y + raggio * sin(angolo))
            i == 0 ? p.move(to: punto) : p.addLine(to: punto)
        }
        p.closeSubpath()
        return p
    }
}

struct SagomaCuore: Shape {
    func path(in rect: CGRect) -> Path {
        let l = rect.width, a = rect.height
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + l / 2, y: rect.maxY))
        p.addCurve(to: CGPoint(x: rect.minX, y: rect.minY + a * 0.32),
                   control1: CGPoint(x: rect.minX + l * 0.1, y: rect.minY + a * 0.8),
                   control2: CGPoint(x: rect.minX, y: rect.minY + a * 0.55))
        p.addArc(center: CGPoint(x: rect.minX + l * 0.25, y: rect.minY + a * 0.32),
                 radius: l * 0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addArc(center: CGPoint(x: rect.minX + l * 0.75, y: rect.minY + a * 0.32),
                 radius: l * 0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addCurve(to: CGPoint(x: rect.minX + l / 2, y: rect.maxY),
                   control1: CGPoint(x: rect.maxX, y: rect.minY + a * 0.55),
                   control2: CGPoint(x: rect.minX + l * 0.9, y: rect.minY + a * 0.8))
        return p
    }
}
