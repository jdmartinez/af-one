import SwiftUI

extension Color {
    static var cardBackground: Color {
        Color(.systemBackground)
    }
    
    static var secondaryText: Color {
        Color.secondary
    }
    
    static var secondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var divider: Color {
        Color(.separator)
    }
    
    static var cardShadow: Color {
        Color.black.opacity(0.1)
    }
}

enum AFStatusColor {
    static let normal = Color.green
    static let af = Color.red
    static let unknown = Color.gray
    
    static func color(for status: RhythmStatus) -> Color {
        switch status {
        case .normal:
            return normal
        case .af:
            return af
        case .unknown:
            return unknown
        }
    }
}

enum HRColor {
    static let normal = Color.green
    static let elevated = Color.orange
    static let high = Color.red
    
    static func color(for bpm: Int) -> Color {
        switch bpm {
        case ..<60:
            return normal
        case 60..<100:
            return normal
        case 100..<120:
            return elevated
        default:
            return high
        }
    }
}

enum BurdenColor {
    static let low = Color.green
    static let moderate = Color.yellow
    static let high = Color.orange
    static let veryHigh = Color.red
    
    static func color(for burden: Double) -> Color {
        switch burden {
        case ..<1:
            return low
        case 1..<5:
            return moderate
        case 5..<10:
            return high
        default:
            return veryHigh
        }
    }
}

enum ChartColors {
    static let primary = Color.blue
    static let secondary = Color.purple
    static let tertiary = Color.orange
    static let background = Color(.systemGroupedBackground)
}
