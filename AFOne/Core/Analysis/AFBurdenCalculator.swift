import Foundation
import HealthKit

/// TimePeriod - Enum for different analysis time windows
enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
    
    var id: String { rawValue }
    
    /// Returns the display name for short picker (e.g., "6M", "1Y")
    var shortName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .sixMonths: return "6M"
        case .oneYear: return "1Y"
        }
    }
    
    var dateRange: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .day:
            return DateInterval(start: calendar.date(byAdding: .day, value: -1, to: now)!, end: now)
        case .week:
            return DateInterval(start: calendar.date(byAdding: .weekOfYear, value: -1, to: now)!, end: now)
        case .month:
            return DateInterval(start: calendar.date(byAdding: .month, value: -1, to: now)!, end: now)
        case .sixMonths:
            return DateInterval(start: calendar.date(byAdding: .month, value: -6, to: now)!, end: now)
        case .oneYear:
            return DateInterval(start: calendar.date(byAdding: .year, value: -1, to: now)!, end: now)
        }
    }
    
    /// Calendar component for data aggregation
    var aggregationInterval: Calendar.Component {
        switch self {
        case .day: return .hour
        case .week: return .day
        case .month: return .day
        case .sixMonths: return .weekOfYear  // ~26 points
        case .oneYear: return .month        // 12 points
        }
    }
    
    /// Number of data points for chart visualization
    var chartPointCount: Int {
        switch self {
        case .day: return 24
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 26
        case .oneYear: return 12
        }
    }
    
    var chartDataInterval: Calendar.Component {
        switch self {
        case .day: return .hour
        case .week: return .day
        case .month: return .day
        case .sixMonths: return .weekOfYear
        case .oneYear: return .month
        }
    }
}

/// BurdenDataPoint - Single data point for burden visualization
struct BurdenDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let percentage: Double
}

/// AFBurdenCalculator - Actor for calculating AF burden across time periods
actor AFBurdenCalculator {
    static let shared = AFBurdenCalculator()
    
    private init() {}
    
    /// Calculate burden for a given time period
    func calculateBurden(for period: TimePeriod) async throws -> Double {
        let interval = period.dateRange
        return try await calculateBurden(from: interval.start, to: interval.end)
    }
    
    /// Calculate burden between two dates (original method)
    func calculateBurden(from startDate: Date, to endDate: Date) async throws -> Double {
        // Get all episodes in the time range
        let episodes = try await HealthKitService.shared.fetchEpisodes(from: startDate, to: endDate)
        
        // If no episodes, return 0
        guard !episodes.isEmpty else {
            return 0.0
        }
        
        // Calculate total AF time
        let totalAfTime = episodes.reduce(0.0) { $0 + $1.duration }
        
        // Calculate total time range in seconds
        let totalRangeTime = endDate.timeIntervalSince(startDate)
        
        // Return as percentage
        guard totalRangeTime > 0 else { return 0.0 }
        return (totalAfTime / totalRangeTime) * 100.0
    }
    
    /// Get chart data points for visualization
    func getChartData(for period: TimePeriod) async throws -> [BurdenDataPoint] {
        let interval = period.dateRange
        let episodes = try await HealthKitService.shared.fetchEpisodes(from: interval.start, to: interval.end)
        
        guard !episodes.isEmpty else {
            return generateEmptyDataPoints(for: period)
        }
        
        let calendar = Calendar.current
        var dataPoints: [BurdenDataPoint] = []
        
        switch period {
        case .day:
            // Hourly breakdown (last 24 hours)
            for hourOffset in 0..<24 {
                if let hourDate = calendar.date(byAdding: .hour, value: -hourOffset, to: Date()) {
                    let hourStart = calendar.startOfHour(for: hourDate)
                    let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart)!
                    
                    let burden = try await calculateBurden(from: hourStart, to: hourEnd)
                    dataPoints.append(BurdenDataPoint(date: hourStart, percentage: burden))
                }
            }
        case .week:
            // Daily breakdown (last 7 days)
            for dayOffset in 0..<7 {
                if let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                    let dayStart = calendar.startOfDay(for: dayDate)
                    let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                    
                    let burden = try await calculateBurden(from: dayStart, to: dayEnd)
                    dataPoints.append(BurdenDataPoint(date: dayStart, percentage: burden))
                }
            }
        case .month:
            // Daily breakdown (last 30 days)
            for dayOffset in 0..<30 {
                if let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                    let dayStart = calendar.startOfDay(for: dayDate)
                    let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                    
                    let burden = try await calculateBurden(from: dayStart, to: dayEnd)
                    dataPoints.append(BurdenDataPoint(date: dayStart, percentage: burden))
                }
            }
        case .sixMonths:
            // Weekly breakdown (last 26 weeks)
            for weekOffset in 0..<26 {
                if let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()) {
                    let weekStart = calendar.startOfDay(for: weekDate)
                    let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
                    
                    let burden = try await calculateBurden(from: weekStart, to: weekEnd)
                    dataPoints.append(BurdenDataPoint(date: weekStart, percentage: burden))
                }
            }
        case .oneYear:
            // Monthly breakdown (last 12 months)
            for monthOffset in 0..<12 {
                if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
                    let monthStart = calendar.startOfDay(for: monthDate)
                    let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
                    
                    let burden = try await calculateBurden(from: monthStart, to: monthEnd)
                    dataPoints.append(BurdenDataPoint(date: monthStart, percentage: burden))
                }
            }
        }
        
        return dataPoints.reversed()
    }
    
    /// Generate empty data points when no episodes exist
    private func generateEmptyDataPoints(for period: TimePeriod) -> [BurdenDataPoint] {
        let calendar = Calendar.current
        var dataPoints: [BurdenDataPoint] = []
        
        switch period {
        case .day:
            for hourOffset in 0..<24 {
                if let hourDate = calendar.date(byAdding: .hour, value: -hourOffset, to: Date()) {
                    let hourStart = calendar.startOfHour(for: hourDate)
                    dataPoints.append(BurdenDataPoint(date: hourStart, percentage: 0))
                }
            }
        case .week:
            for dayOffset in 0..<7 {
                if let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                    let dayStart = calendar.startOfDay(for: dayDate)
                    dataPoints.append(BurdenDataPoint(date: dayStart, percentage: 0))
                }
            }
        case .month:
            for dayOffset in 0..<30 {
                if let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                    let dayStart = calendar.startOfDay(for: dayDate)
                    dataPoints.append(BurdenDataPoint(date: dayStart, percentage: 0))
                }
            }
        case .sixMonths:
            for weekOffset in 0..<26 {
                if let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()) {
                    let weekStart = calendar.startOfDay(for: weekDate)
                    dataPoints.append(BurdenDataPoint(date: weekStart, percentage: 0))
                }
            }
        case .oneYear:
            for monthOffset in 0..<12 {
                if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
                    let monthStart = calendar.startOfDay(for: monthDate)
                    dataPoints.append(BurdenDataPoint(date: monthStart, percentage: 0))
                }
            }
        }
        
        return dataPoints.reversed()
    }
}

// MARK: - Calendar Extension for startOfHour

private extension Calendar {
    func startOfHour(for date: Date) -> Date {
        let components = dateComponents([.year, .month, .day, .hour], from: date)
        return self.date(from: components) ?? date
    }
}
