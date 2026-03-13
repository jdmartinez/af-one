import Foundation
import SwiftUI

/// ReportData - Data structure for clinical report content
struct ReportData {
    let period: TimePeriod
    let startDate: Date
    let endDate: Date
    
    var burden: Double
    var burdenTrend: TrendIndicator?
    
    var episodes: Int
    var episodesOver1Hour: Int
    
    var avgHR: Int
    var maxHR: Int
    
    var symptomCount: Int
    var symptomsDuringAF: Int
    var topTriggers: [String]
    
    var medications: [MedicationInfo]
    
    /// Initialize with default empty values
    init(
        period: TimePeriod,
        startDate: Date,
        endDate: Date,
        burden: Double = 0,
        burdenTrend: TrendIndicator? = nil,
        episodes: Int = 0,
        episodesOver1Hour: Int = 0,
        avgHR: Int = 0,
        maxHR: Int = 0,
        symptomCount: Int = 0,
        symptomsDuringAF: Int = 0,
        topTriggers: [String] = [],
        medications: [MedicationInfo] = []
    ) {
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.burden = burden
        self.burdenTrend = burdenTrend
        self.episodes = episodes
        self.episodesOver1Hour = episodesOver1Hour
        self.avgHR = avgHR
        self.maxHR = maxHR
        self.symptomCount = symptomCount
        self.symptomsDuringAF = symptomsDuringAF
        self.topTriggers = topTriggers
        self.medications = medications
    }
}

/// ReportGenerator - Service for generating clinical summary reports
@MainActor
final class ReportGenerator: ObservableObject {
    static let shared = ReportGenerator()
    
    private let healthKitService = HealthKitService.shared
    private let burdenCalculator = AFBurdenCalculator.shared
    private let trendAnalyzer = TrendAnalyzer.shared
    
    private init() {}
    
    /// Generate a clinical summary report for the specified time period
    func generateReport(period: TimePeriod) async throws -> String {
        let dateRange = period.dateRange
        
        // Fetch all required data
        async let burdenData = fetchBurdenData(from: dateRange.start, to: dateRange.end)
        async let episodesData = fetchEpisodesData(from: dateRange.start, to: dateRange.end)
        async let previousBurdenData = fetchPreviousPeriodBurden(period: period)
        async let medications = fetchMedications()
        
        // Await all data
        let (burdens, episodes, previousBurden, meds) = try await (burdenData, episodesData, previousBurdenData, medications)
        
        // Calculate metrics
        let avgBurden = calculateAverageBurden(burdens)
        let burdenTrend = trendAnalyzer.calculateBurdenTrend(
            currentBurden: avgBurden,
            previousBurden: previousBurden
        )
        
        let episodesOver1Hour = episodes.filter { episode in
            let duration = episode.endDate.timeIntervalSince(episode.startDate)
            return duration > 3600 // 1 hour
        }.count
        
        let (avgHR, maxHR) = calculateHeartRateMetrics(episodes: episodes)
        
        // Fetch symptom and trigger data (using sample data for now)
        let symptomCount = 0
        let symptomsDuringAF = 0
        let topTriggers: [String] = []
        
        // Build report data
        let reportData = ReportData(
            period: period,
            startDate: dateRange.start,
            endDate: dateRange.end,
            burden: avgBurden,
            burdenTrend: burdenTrend,
            episodes: episodes.count,
            episodesOver1Hour: episodesOver1Hour,
            avgHR: avgHR,
            maxHR: maxHR,
            symptomCount: symptomCount,
            symptomsDuringAF: symptomsDuringAF,
            topTriggers: topTriggers,
            medications: meds
        )
        
        // Generate formatted report string
        return formatReport(data: reportData)
    }
    
    // MARK: - Private Helpers
    
    private func fetchBurdenData(from startDate: Date, to endDate: Date) async throws -> [AFBurden] {
        return try await healthKitService.fetchAfBurden(from: startDate, to: endDate)
    }
    
    private func fetchEpisodesData(from startDate: Date, to endDate: Date) async throws -> [RhythmEpisode] {
        return try await healthKitService.fetchEpisodes(from: startDate, to: endDate)
    }
    
    private func fetchPreviousPeriodBurden(period: TimePeriod) async throws -> Double {
        let calendar = Calendar.current
        let currentRange = period.dateRange
        
        // Calculate previous period range
        let previousEndDate = currentRange.start
        let previousStartDate: Date
        
        switch period {
        case .day:
            previousStartDate = calendar.date(byAdding: .day, value: -1, to: previousEndDate)!
        case .week:
            previousStartDate = calendar.date(byAdding: .weekOfYear, value: -1, to: previousEndDate)!
        case .month:
            previousStartDate = calendar.date(byAdding: .month, value: -1, to: previousEndDate)!
        case .sixMonths:
            previousStartDate = calendar.date(byAdding: .month, value: -6, to: previousEndDate)!
        case .oneYear:
            previousStartDate = calendar.date(byAdding: .year, value: -1, to: previousEndDate)!
        }
        
        let burdens = try await healthKitService.fetchAfBurden(from: previousStartDate, to: previousEndDate)
        return calculateAverageBurden(burdens)
    }
    
    private func fetchMedications() async throws -> [MedicationInfo] {
        return try await healthKitService.fetchMedications()
    }
    
    private func calculateAverageBurden(_ burdens: [AFBurden]) -> Double {
        guard !burdens.isEmpty else { return 0 }
        let total = burdens.reduce(0.0) { $0 + $1.percentage }
        return total / Double(burdens.count)
    }
    
    private func calculateHeartRateMetrics(episodes: [RhythmEpisode]) -> (avg: Int, max: Int) {
        guard !episodes.isEmpty else { return (0, 0) }
        
        let totalHR = episodes.reduce(0) { $0 + $1.averageHR }
        let avg = totalHR / episodes.count
        
        let max = episodes.map { $0.peakHR }.max() ?? 0
        
        return (avg, max)
    }
    
    // MARK: - Report Formatting
    
    private func formatReport(data: ReportData) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let startStr = dateFormatter.string(from: data.startDate)
        let endStr = dateFormatter.string(from: data.endDate)
        
        var report = """
        AF CLINICAL SUMMARY
        ==================
        Patient Period: \(startStr) - \(endStr)
        
        KEY METRICS
        -----------
        """
        
        // AF Burden
        if data.burden > 0 {
            let trendText = data.burdenTrend?.displayText ?? "→ 0.0%"
            report += "\n- AF Burden: \(String(format: "%.1f", data.burden))% (\(trendText) previous period)"
        } else {
            report += "\n- AF Burden: No data available"
        }
        
        // Episodes
        if data.episodes > 0 {
            report += "\n- Episodes: \(data.episodes) total, \(data.episodesOver1Hour) lasting >1 hour"
        } else {
            report += "\n- Episodes: No episodes recorded"
        }
        
        // Heart rate
        if data.avgHR > 0 {
            report += "\n- Average HR during episodes: \(data.avgHR) BPM"
        } else {
            report += "\n- Average HR during episodes: No data available"
        }
        
        if data.maxHR > 0 {
            report += "\n- Max HR during episodes: \(data.maxHR) BPM"
        }
        
        // Trends
        report += """
        
        
        TRENDS
        ------
        """
        
        if let burdenTrend = data.burdenTrend {
            report += "\n[\(burdenTrend.direction.rawValue)] AF Burden: \(burdenTrend.displayText) change from previous period"
        } else {
            report += "\n[→] AF Burden: No previous data available"
        }
        
        // Symptoms
        report += """
        
        
        SYMPTOMS
        --------
        """
        
        if data.symptomCount > 0 {
            report += "\n- \(data.symptomCount) symptoms logged, \(data.symptomsDuringAF) during AF episodes"
        } else {
            report += "\n- No symptoms logged"
        }
        
        if !data.topTriggers.isEmpty {
            report += "\n- Top triggers: \(data.topTriggers.joined(separator: ", "))"
        } else {
            report += "\n- Top triggers: None identified"
        }
        
        // Medications
        report += """
        
        
        MEDICATIONS (from Apple Health)
        ------------------------------
        """
        
        if !data.medications.isEmpty {
            for med in data.medications {
                var medLine = "- \(med.name)"
                if let dose = med.dose {
                    medLine += " (\(dose))"
                }
                if let frequency = med.frequency {
                    medLine += " - \(frequency)"
                }
                report += "\n\(medLine)"
            }
        } else {
            report += "\n- No medications recorded in Apple Health"
        }
        
        // Disclaimer
        report += """
        
        
        ---
        Generated by AFOne. This report is for informational purposes only and does not constitute medical advice. Please consult with your cardiologist for medical decisions.
        """
        
        return report
    }
}
