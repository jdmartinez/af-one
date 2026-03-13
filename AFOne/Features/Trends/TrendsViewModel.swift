import Foundation
import SwiftUI

/// TrendsViewModel - Manages long-term trend data and state
@MainActor
final class TrendsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedPeriod: TimePeriod = .sixMonths
    @Published var burdenData: [BurdenDataPoint] = []
    @Published var burdenTrend: TrendIndicator?
    @Published var episodeTrend: TrendIndicator?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Date range label for the selected period
    var periodDateRangeLabel: String {
        let formatter = DateFormatter()
        
        switch selectedPeriod {
        case .day:
            formatter.dateFormat = "MMM d, h a"
            let now = Date()
            let start = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .week:
            formatter.dateFormat = "MMM d"
            let now = Date()
            let start = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .month:
            formatter.dateFormat = "MMM d"
            let now = Date()
            let start = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .sixMonths:
            formatter.dateFormat = "MMM yyyy"
            let now = Date()
            let start = Calendar.current.date(byAdding: .month, value: -6, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        case .oneYear:
            formatter.dateFormat = "MMM yyyy"
            let now = Date()
            let start = Calendar.current.date(byAdding: .year, value: -1, to: now)!
            return "\(formatter.string(from: start)) - \(formatter.string(from: now))"
        }
    }
    
    // MARK: - Public Methods
    
    /// Load trends data for the selected period
    func loadTrends() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get chart data for visualization
            let data = try await AFBurdenCalculator.shared.getChartData(for: selectedPeriod)
            burdenData = data
            
            // Calculate trends by comparing current period to previous period
            await calculateTrends(for: selectedPeriod)
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load trends: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    /// Calculate trend indicators by comparing current vs previous period
    private func calculateTrends(for period: TimePeriod) async {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate date ranges for current and previous periods
        let (currentStart, currentEnd) = getDateRange(for: period, from: now)
        
        // Calculate previous period dates based on period type
        let previousEnd = currentStart
        let previousStart: Date
        switch period {
        case .day:
            previousStart = calendar.date(byAdding: .day, value: -1, to: currentStart)!
        case .week:
            previousStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentStart)!
        case .month:
            previousStart = calendar.date(byAdding: .month, value: -1, to: currentStart)!
        case .sixMonths:
            previousStart = calendar.date(byAdding: .month, value: -6, to: currentStart)!
        case .oneYear:
            previousStart = calendar.date(byAdding: .year, value: -1, to: currentStart)!
        }
        
        do {
            // Calculate burden for current period
            let currentBurden = try await AFBurdenCalculator.shared.calculateBurden(
                from: currentStart,
                to: currentEnd
            )
            
            // Calculate burden for previous period
            let previousBurden = try await AFBurdenCalculator.shared.calculateBurden(
                from: previousStart,
                to: previousEnd
            )
            
            // Calculate burden trend
            burdenTrend = TrendAnalyzer.shared.calculateBurdenTrend(
                currentBurden: currentBurden,
                previousBurden: previousBurden
            )
            
            // Calculate episode counts for trend
            let currentEpisodes = try await HealthKitService.shared.fetchEpisodes(
                from: currentStart,
                to: currentEnd
            )
            
            let previousEpisodes = try await HealthKitService.shared.fetchEpisodes(
                from: previousStart,
                to: previousEnd
            )
            
            // Calculate episode frequency trend
            episodeTrend = TrendAnalyzer.shared.calculateEpisodeFrequencyTrend(
                currentCount: currentEpisodes.count,
                previousCount: previousEpisodes.count
            )
            
        } catch {
            // If we can't calculate trends, set to stable
            burdenTrend = TrendIndicator(
                direction: .stable,
                percentChange: 0.0,
                isSignificant: false
            )
            episodeTrend = TrendIndicator(
                direction: .stable,
                percentChange: 0.0,
                isSignificant: false
            )
        }
    }
    
    /// Get date range for a period ending at a specific date
    private func getDateRange(for period: TimePeriod, from endDate: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch period {
        case .day:
            let start = calendar.date(byAdding: .day, value: -1, to: endDate)!
            return (start, endDate)
        case .week:
            let start = calendar.date(byAdding: .weekOfYear, value: -1, to: endDate)!
            return (start, endDate)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: endDate)!
            return (start, endDate)
        case .sixMonths:
            let start = calendar.date(byAdding: .month, value: -6, to: endDate)!
            return (start, endDate)
        case .oneYear:
            let start = calendar.date(byAdding: .year, value: -1, to: endDate)!
            return (start, endDate)
        }
    }
}
