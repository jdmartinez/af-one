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
        let rhythmSinusal = Color("AFOneRhythmSinusal")
        let rhythmAF = Color("AFOneRhythmAF")
        let burdenLow = Color("AFOneBurdenLow")
        let burdenMid = Color("AFOneBurdenMid")
        let burdenHigh = Color("AFOneBurdenHigh")
        
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

// MARK: - Hero Gradient Colors
struct HeroGradient {
    static let sr = [
        Color("HeroSR1"),
        Color("HeroSR2"),
        Color("HeroSR3")
    ]
    
    static let af = [
        Color("HeroAF1"),
        Color("HeroAF2"),
        Color("HeroAF3")
    ]
}

// MARK: - Burden Gradient Colors
struct BurdenGradient {
    /// Dark green gradient for low burden (<5.5%)
    static let low = [
        Color(red: 0.05, green: 0.25, blue: 0.15),
        Color(red: 0.08, green: 0.35, blue: 0.20),
        Color(red: 0.10, green: 0.45, blue: 0.25)
    ]
    
    /// Amber/orange gradient for medium burden (5.5-10.9%)
    static let medium = [
        Color(red: 0.35, green: 0.20, blue: 0.05),
        Color(red: 0.45, green: 0.25, blue: 0.05),
        Color(red: 0.55, green: 0.30, blue: 0.08)
    ]
    
    /// Dark red gradient for high burden (>=11%)
    static let high = [
        Color(red: 0.30, green: 0.05, blue: 0.10),
        Color(red: 0.40, green: 0.08, blue: 0.12),
        Color(red: 0.50, green: 0.10, blue: 0.15)
    ]
    
    /// Returns the appropriate gradient colors based on burden percentage
    static func gradient(for percentage: Double) -> [Color] {
        switch percentage {
        case ..<5.5:
            return low
        case 5.5..<11.0:
            return medium
        default:
            return high
        }
    }
}
