import Foundation

enum TrendDirection: String {
    case increasing = "↑"
    case decreasing = "↓"
    case stable = "→"
}

struct TrendIndicator: Identifiable {
    let id = UUID()
    let direction: TrendDirection
    let percentChange: Double
    let isSignificant: Bool
    
    var displayText: String {
        let sign = percentChange >= 0 ? "+" : ""
        return "\(direction.rawValue) \(sign)\(String(format: "%.1f", percentChange))%"
    }
}

struct TrendAnalyzer {
    static let shared = TrendAnalyzer()
    
    private let significantThreshold: Double = 10.0
    
    private init() {}
    
    func calculateTrend(current: Double, previous: Double) -> TrendIndicator {
        guard previous > 0 else {
            if current > 0 {
                return TrendIndicator(direction: .increasing, percentChange: 100.0, isSignificant: true)
            }
            return TrendIndicator(direction: .stable, percentChange: 0.0, isSignificant: false)
        }
        
        let percentChange = ((current - previous) / previous) * 100.0
        let direction: TrendDirection
        if percentChange > significantThreshold {
            direction = .increasing
        } else if percentChange < -significantThreshold {
            direction = .decreasing
        } else {
            direction = .stable
        }
        
        return TrendIndicator(
            direction: direction,
            percentChange: percentChange,
            isSignificant: abs(percentChange) >= significantThreshold
        )
    }
    
    func calculateBurdenTrend(currentBurden: Double, previousBurden: Double) -> TrendIndicator {
        return calculateTrend(current: currentBurden, previous: previousBurden)
    }
    
    func calculateEpisodeFrequencyTrend(currentCount: Int, previousCount: Int) -> TrendIndicator {
        return calculateTrend(current: Double(currentCount), previous: Double(previousCount))
    }
    
    func calculateAverageDurationTrend(currentDuration: TimeInterval, previousDuration: TimeInterval) -> TrendIndicator {
        return calculateTrend(current: currentDuration, previous: previousDuration)
    }
}
