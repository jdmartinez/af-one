import Foundation

struct AFBurden: Identifiable, Codable {
    var id: Date { date }
    let date: Date
    let percentage: Double
    let sampleCount: Int

    var percentageFormatted: String {
        String(format: "%.1f%%", percentage)
    }

    var category: BurdenCategory {
        if percentage < 1 {
            return .low
        } else if percentage < 5 {
            return .moderate
        } else if percentage < 20 {
            return .elevated
        } else {
            return .high
        }
    }
}

enum BurdenCategory {
    case low
    case moderate
    case elevated
    case high

    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .elevated: return "orange"
        case .high: return "red"
        }
    }
}
