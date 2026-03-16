import Foundation
import SwiftUI

enum BurdenPeriod: String, CaseIterable, Identifiable {
    case day = "24h"
    case week = "7 días"
    case month = "30 días"
    
    var id: String { rawValue }
    
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        }
    }
}

struct BurdenData: Identifiable, Equatable {
    let id = UUID()
    let period: BurdenPeriod
    let percentage: Double
    let previousPercentage: Double?
    let episodeCount: Int
    let averageDuration: TimeInterval
    let insufficientData: Bool
}

struct EpisodeSummary: Identifiable {
    let id = UUID()
    let startDate: Date
    let duration: TimeInterval
    let averageHR: Int
    let minSpO2: Int?
    let hasECG: Bool
    let insufficientData: Bool
}

@MainActor
@Observable
final class BurdenDetailViewModel {
    var selectedPeriod: BurdenPeriod = .week
    var currentBurden: BurdenData?
    var allPeriodsBurden: [BurdenData] = []
    var trendData: [BurdenData] = []
    var recentEpisodes: [EpisodeSummary] = []
    var isLoading = false
    
    // Computed
    var burdenLevel: BurdenLevel {
        guard let burden = currentBurden else { return .low }
        if burden.percentage < 5.5 { return .low }
        if burden.percentage < 11 { return .medium }
        return .high
    }
    
    var deltaText: String {
        guard let current = currentBurden, let previous = current.previousPercentage else {
            return "Sin datos previos"
        }
        let delta = current.percentage - previous
        if delta > 0 {
            return "+\(String(format: "%.1f", delta))%"
        }
        return "\(String(format: "%.1f", delta))%"
    }
    
    var deltaIsPositive: Bool {
        guard let current = currentBurden, let previous = current.previousPercentage else {
            return false
        }
        return current.percentage > previous
    }
    
    func loadData() async {
        isLoading = true
        // TODO: Fetch from HealthKit service
        // Placeholder data for now
        currentBurden = BurdenData(
            period: selectedPeriod,
            percentage: 7.2,
            previousPercentage: 5.8,
            episodeCount: 12,
            averageDuration: 1800,
            insufficientData: false
        )
        
        // Load all periods for comparison
        allPeriodsBurden = [
            BurdenData(period: .day, percentage: 8.5, previousPercentage: 6.2, episodeCount: 3, averageDuration: 1200, insufficientData: false),
            BurdenData(period: .week, percentage: 7.2, previousPercentage: 5.8, episodeCount: 12, averageDuration: 1800, insufficientData: false),
            BurdenData(period: .month, percentage: 6.1, previousPercentage: 5.5, episodeCount: 45, averageDuration: 2100, insufficientData: false)
        ]
        
        // Load trend data (14 days)
        trendData = (0..<14).map { day in
            let percentage = Double.random(in: 2...15)
            return BurdenData(
                period: .day,
                percentage: percentage,
                previousPercentage: nil,
                episodeCount: Int.random(in: 0...3),
                averageDuration: TimeInterval.random(in: 600...3600),
                insufficientData: percentage < 3
            )
        }
        
        // Load recent episodes
        recentEpisodes = [
            EpisodeSummary(startDate: Date().addingTimeInterval(-3600), duration: 1800, averageHR: 120, minSpO2: 97, hasECG: true, insufficientData: false),
            EpisodeSummary(startDate: Date().addingTimeInterval(-86400), duration: 2400, averageHR: 110, minSpO2: nil, hasECG: true, insufficientData: false),
            EpisodeSummary(startDate: Date().addingTimeInterval(-172800), duration: 900, averageHR: 135, minSpO2: 96, hasECG: false, insufficientData: false)
        ]
        
        isLoading = false
    }
}
