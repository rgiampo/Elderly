import SwiftUI

/// Le forme del gioco: ognuna ha un colore e una nota (do, re, mi, fa, sol),
/// così si possono suonare melodie conosciute.
enum Forma: CaseIterable, Identifiable {
    case cerchio, quadrato, triangolo, stella, cuore

    var id: Self { self }

    /// Nome letto da VoiceOver: forma e colore, così non si dipende dal solo colore.
    var nome: String {
        switch self {
        case .cerchio: "Cerchio rosso"
        case .quadrato: "Quadrato blu"
        case .triangolo: "Triangolo giallo"
        case .stella: "Stella verde"
        case .cuore: "Cuore rosa"
        }
    }

    var colore: Color {
        switch self {
        case .cerchio: Color(red: 0.93, green: 0.30, blue: 0.30)
        case .quadrato: Color(red: 0.25, green: 0.50, blue: 0.95)
        case .triangolo: Color(red: 0.98, green: 0.75, blue: 0.15)
        case .stella: Color(red: 0.25, green: 0.72, blue: 0.40)
        case .cuore: Color(red: 0.95, green: 0.45, blue: 0.70)
        }
    }

    /// Do, re, mi, fa, sol (quinta ottava): bastano per l'Inno alla gioia e per Fra Martino.
    var frequenza: Double {
        switch self {
        case .cerchio: 523.25
        case .quadrato: 587.33
        case .triangolo: 659.25
        case .stella: 698.46
        case .cuore: 783.99
        }
    }

    var sagoma: AnyShape {
        switch self {
        case .cerchio: AnyShape(Circle())
        case .quadrato: AnyShape(Rectangle())
        case .triangolo: AnyShape(SagomaTriangolo())
        case .stella: AnyShape(SagomaStella())
        case .cuore: AnyShape(SagomaCuore())
        }
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
