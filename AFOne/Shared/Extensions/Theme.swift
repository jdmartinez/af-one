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
        Color.primary.opacity(0.1)
    }
    
    // MARK: - AFOne Brand Colors
    static let afOne = AFOneColors()
    
    struct AFOneColors {
        let rhythmSinusal = Color(red: 0.22, green: 0.76, blue: 0.38)
        let rhythmAF = Color(red: 0.84, green: 0.27, blue: 0.27)
        let burdenLow = Color(red: 0.22, green: 0.76, blue: 0.38)
        let burdenMid = Color(red: 0.98, green: 0.73, blue: 0.09)
        let burdenHigh = Color(red: 0.84, green: 0.27, blue: 0.27)
        
        /// Returns the appropriate burden color based on percentage thresholds
        /// - Parameter percentage: The AF burden percentage (0-100)
        /// - Returns: The corresponding burden color (low < 5.5%, mid 5.5-10.9%, high >= 11%)
        func burdenColor(for percentage: Double) -> Color {
            switch percentage {
            case ..<5.5:
                return burdenLow
            case 5.5..<11.0:
                return burdenMid
            default:
                return burdenHigh
            }
        }
    }
}

// MARK: - Status Colors
enum AFStatusColor {
    static let normal = Color.afOne.rhythmSinusal
    static let af = Color.afOne.rhythmAF
    static let unknown = Color(.systemGray)
    
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

// MARK: - Heart Rate Colors
enum HRColor {
    static let normal = Color.afOne.rhythmSinusal
    static let elevated = Color.afOne.burdenMid
    static let high = Color.afOne.rhythmAF
    
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

// MARK: - Burden Colors (legacy - use Color.afOne.burdenColor instead)
enum BurdenColor {
    static let low = Color.afOne.burdenLow
    static let moderate = Color.afOne.burdenMid
    static let high = Color.afOne.burdenMid
    static let veryHigh = Color.afOne.burdenHigh
    
    static func color(for burden: Double) -> Color {
        return Color.afOne.burdenColor(for: burden)
    }
}

// MARK: - Chart Colors
enum ChartColors {
    static let primary = Color(.systemBlue)
    static let secondary = Color(.systemPurple)
    static let tertiary = Color.afOne.burdenMid
    static let background = Color(.systemGroupedBackground)
}
