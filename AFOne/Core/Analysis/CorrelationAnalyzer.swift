import Foundation
import SwiftData

/// CorrelationResult - Overall symptom-AF correlation result
struct CorrelationResult: Identifiable {
    let id = UUID()
    let symptomsWithAf: Int
    let symptomsWithoutAf: Int
    let totalSymptoms: Int
    
    var afCooccurrenceRate: Double {
        guard totalSymptoms > 0 else { return 0 }
        return Double(symptomsWithAf) / Double(totalSymptoms)
    }
    
    var normalRate: Double {
        guard totalSymptoms > 0 else { return 0 }
        return Double(symptomsWithoutAf) / Double(totalSymptoms)
    }
}

/// SymptomCorrelation - Per-symptom correlation breakdown
struct SymptomCorrelation: Identifiable {
    let id = UUID()
    let symptomType: SymptomType
    let occurrencesWithAf: Int
    let occurrencesWithoutAf: Int
    
    var totalOccurrences: Int {
        occurrencesWithAf + occurrencesWithoutAf
    }
    
    var afCorrelation: Double {
        guard totalOccurrences > 0 else { return 0 }
        return Double(occurrencesWithAf) / Double(totalOccurrences)
    }
}

/// TriggerCorrelation - Per-trigger correlation breakdown
struct TriggerCorrelation: Identifiable {
    let id = UUID()
    let triggerType: TriggerType
    let occurrencesWithAf: Int
    let occurrencesWithoutAf: Int
    
    var totalOccurrences: Int {
        occurrencesWithAf + occurrencesWithoutAf
    }
    
    var afCorrelation: Double {
        guard totalOccurrences > 0 else { return 0 }
        return Double(occurrencesWithAf) / Double(totalOccurrences)
    }
}

/// EpisodeHeartRateAnalysis - Heart rate analysis during AF episodes
struct EpisodeHeartRateAnalysis {
    let averageHeartRate: Double
    let peakHeartRate: Double
    let episodesWithHighHR: Int
    let totalEpisodesAnalyzed: Int
    
    var hasUnusuallyHighHR: Bool {
        episodesWithHighHR > 0
    }
}

// MARK: - Phase 11: Window-Based Correlation Extensions

/// CorrelationSummary — aggregates for the three-column summary grid (SYMP-01)
struct CorrelationSummary {
    /// Síntomas con FA (green) — symptoms within ±30min of an AF episode
    let symptomsWithAf: Int
    /// Síntomas sin FA (amber) — symptoms outside any AF episode window
    let symptomsWithoutAf: Int
    /// FA silente (red) — AF episodes without any symptoms in ±30min window
    let silentAfEpisodeCount: Int
    let totalSymptoms: Int

    static let empty = CorrelationSummary(
        symptomsWithAf: 0,
        symptomsWithoutAf: 0,
        silentAfEpisodeCount: 0,
        totalSymptoms: 0
    )
}

/// RhythmState — rhythm classification for detail display (SYMP-05)
enum RhythmState: String {
    case af = "FA"
    case sr = "RS"
    case unknown = "?"
}

/// CorrelationType — badge type for event list (SYMP-04)
enum CorrelationType: String {
    case faConfirmed = "FA confirmada"
    case noCorrelation = "Sin correlación"
    case silentAF = "FA silente"

    var colorName: String {
        switch self {
        case .faConfirmed: return "green"
        case .noCorrelation: return "amber"
        case .silentAF: return "red"
        }
    }
}

/// CorrelationItem — per-event for event list and detail sheet (SYMP-04, SYMP-05)
/// For silent AF items, symptom is nil and syntheticSymptomType is set instead.
struct CorrelationItem: Identifiable {
    let id = UUID()
    /// The logged symptom. Nil for synthetic silent AF items.
    let symptom: SymptomLog?
    let rhythmState: RhythmState
    let correlationType: CorrelationType
    /// The overlapping episode for FA-confirmed items; nil for silent AF items
    let overlappingEpisode: RhythmEpisode?
    let windowStart: Date
    let windowEnd: Date
    /// Non-nil for synthetic silent AF items (provides display type + timestamp from episode)
    let syntheticSymptomType: SymptomType?
    /// The episode this item represents (used for silent AF items)
    let episode: RhythmEpisode?

    /// Factory for silent AF items (episodes without symptoms in ±30min window)
    static func silentAF(from episode: RhythmEpisode) -> CorrelationItem {
        CorrelationItem(
            symptom: nil,
            rhythmState: .af,
            correlationType: .silentAF,
            overlappingEpisode: episode,
            windowStart: episode.startDate.addingTimeInterval(-CorrelationAnalyzer.windowSeconds),
            windowEnd: episode.endDate.addingTimeInterval(CorrelationAnalyzer.windowSeconds),
            syntheticSymptomType: .palpitations,
            episode: episode
        )
    }
}

/// CorrelationAnalyzer extension for Phase 11 window-based analysis
extension CorrelationAnalyzer {

    /// Standard correlation window in seconds (30 minutes each side)
    static let windowSeconds: TimeInterval = 30 * 60

    /// Analyze symptom-AF correlation using ±30min window (SYMP-01, SYMP-04, SYMP-05)
    /// - Parameters:
    ///   - symptoms: All symptoms in the analysis window
    ///   - episodes: All AF episodes in the analysis window
    /// - Returns: CorrelationSummary with three counts for the summary grid
    func analyzeWithWindow(
        symptoms: [SymptomLog],
        episodes: [RhythmEpisode]
    ) -> CorrelationSummary {
        var symptomsWithAf = 0
        var symptomsWithoutAf = 0

        for symptom in symptoms {
            let hasOverlap = episodes.contains { episode in
                windowOverlaps(symptom: symptom, episode: episode)
            }

            if hasOverlap {
                symptomsWithAf += 1
            } else {
                symptomsWithoutAf += 1
            }
        }

        // FA silente: episodes with NO symptoms in ±30min window
        var silentAfCount = 0
        for episode in episodes {
            let hasSymptom = symptoms.contains { symptom in
                windowOverlaps(symptom: symptom, episode: episode)
            }
            if !hasSymptom {
                silentAfCount += 1
            }
        }

        return CorrelationSummary(
            symptomsWithAf: symptomsWithAf,
            symptomsWithoutAf: symptomsWithoutAf,
            silentAfEpisodeCount: silentAfCount,
            totalSymptoms: symptoms.count
        )
    }

    /// Get per-item correlation list for event list display (SYMP-04)
    func correlationItems(
        symptoms: [SymptomLog],
        episodes: [RhythmEpisode]
    ) -> [CorrelationItem] {
        var items: [CorrelationItem] = []

        for symptom in symptoms {
            let overlapping = episodes.first { windowOverlaps(symptom: symptom, episode: $0) }

            let (rhythmState, correlationType): (RhythmState, CorrelationType) = if overlapping != nil {
                (.af, .faConfirmed)
            } else {
                (.sr, .noCorrelation)
            }

            let windowStart = symptom.timestamp.addingTimeInterval(-Self.windowSeconds)
            let windowEnd = symptom.timestamp.addingTimeInterval(Self.windowSeconds)

            items.append(CorrelationItem(
                symptom: symptom,
                rhythmState: rhythmState,
                correlationType: correlationType,
                overlappingEpisode: overlapping,
                windowStart: windowStart,
                windowEnd: windowEnd,
                syntheticSymptomType: nil,
                episode: nil
            ))
        }

        // Add silent AF items (episodes without symptoms in ±30min window)
        for episode in episodes {
            let hasSymptom = symptoms.contains { windowOverlaps(symptom: $0, episode: episode) }
            if !hasSymptom {
                items.append(.silentAF(from: episode))
            }
        }

        return items.sorted { item1, item2 in
            let date1 = item1.symptom?.timestamp ?? item1.episode?.startDate ?? .distantPast
            let date2 = item2.symptom?.timestamp ?? item2.episode?.startDate ?? .distantPast
            return date1 > date2
        }
    }

    /// Detect pattern: symptoms preceding AF episodes (SYMP-06)
    /// Returns count of symptoms occurring 2h before an AF episode starts but outside ±30min correlation window
    func detectSymptomsPrecedingAF(
        symptoms: [SymptomLog],
        episodes: [RhythmEpisode]
    ) -> Int {
        var count = 0
        let twoHours: TimeInterval = 2 * 60 * 60

        for symptom in symptoms {
            for episode in episodes {
                // Symptom in 2h before episode start, but outside the ±30min window
                let isInPrecedingWindow = symptom.timestamp < episode.startDate
                    && symptom.timestamp >= episode.startDate.addingTimeInterval(-twoHours)
                let isOutsideCorrelationWindow = symptom.timestamp < episode.startDate.addingTimeInterval(-Self.windowSeconds)
                    || symptom.timestamp > episode.endDate.addingTimeInterval(Self.windowSeconds)

                if isInPrecedingWindow && isOutsideCorrelationWindow {
                    count += 1
                    break // Count each symptom only once
                }
            }
        }
        return count
    }

    /// Detect pattern: nocturnal symptoms without AF (SYMP-06)
    /// Returns count of symptoms occurring between 11pm-6am without coincident AF
    func detectNocturnalSymptomsWithoutAF(
        symptoms: [SymptomLog],
        episodes: [RhythmEpisode]
    ) -> Int {
        let calendar = Calendar.current
        var count = 0

        for symptom in symptoms {
            let hour = calendar.component(.hour, from: symptom.timestamp)
            let isNocturnal = hour >= 23 || hour < 6

            guard isNocturnal else { continue }

            let hasOverlap = episodes.contains { windowOverlaps(symptom: symptom, episode: $0) }
            if !hasOverlap {
                count += 1
            }
        }
        return count
    }

    // MARK: - Private Helpers

    /// Check if a symptom's ±30min window overlaps with an AF episode
    private func windowOverlaps(symptom: SymptomLog, episode: RhythmEpisode) -> Bool {
        let windowStart = symptom.timestamp.addingTimeInterval(-Self.windowSeconds)
        let windowEnd = symptom.timestamp.addingTimeInterval(Self.windowSeconds)

        // Overlap exists if: episode starts before window ends AND episode ends after window starts
        return episode.startDate <= windowEnd && episode.endDate >= windowStart
    }
}

/// CorrelationAnalyzer - Actor for analyzing symptom-AF correlations
actor CorrelationAnalyzer {
    /// Analyze correlation between symptoms and AF episodes
    func analyzeCorrelation(symptoms: [SymptomLog], episodes: [RhythmEpisode]) -> CorrelationResult {
        var withAf = 0
        var withoutAf = 0
        
        for symptom in symptoms {
            let occursDuringEpisode = episodes.contains { episode in
                symptom.timestamp >= episode.startDate && symptom.timestamp <= episode.endDate
            }
            
            if occursDuringEpisode {
                withAf += 1
            } else {
                withoutAf += 1
            }
        }
        
        return CorrelationResult(
            symptomsWithAf: withAf,
            symptomsWithoutAf: withoutAf,
            totalSymptoms: symptoms.count
        )
    }
    
    /// Get per-symptom correlation breakdown
    func analyzeSymptomBreakdown(symptoms: [SymptomLog], episodes: [RhythmEpisode]) -> [SymptomCorrelation] {
        var correlations: [SymptomCorrelation] = []
        
        for symptomType in SymptomType.allCases {
            let typeSymptoms = symptoms.filter { $0.symptomType == symptomType.rawValue }
            
            var withAf = 0
            var withoutAf = 0
            
            for symptom in typeSymptoms {
                let occursDuringEpisode = episodes.contains { episode in
                    symptom.timestamp >= episode.startDate && symptom.timestamp <= episode.endDate
                }
                
                if occursDuringEpisode {
                    withAf += 1
                } else {
                    withoutAf += 1
                }
            }
            
            correlations.append(SymptomCorrelation(
                symptomType: symptomType,
                occurrencesWithAf: withAf,
                occurrencesWithoutAf: withoutAf
            ))
        }
        
        return correlations
    }
    
    /// Get per-trigger correlation breakdown
    func analyzeTriggerBreakdown(triggers: [TriggerLog], episodes: [RhythmEpisode]) -> [TriggerCorrelation] {
        var correlations: [TriggerCorrelation] = []
        
        for triggerType in TriggerType.allCases {
            let typeTriggers = triggers.filter { $0.triggerType == triggerType.rawValue }
            
            var withAf = 0
            var withoutAf = 0
            
            for trigger in typeTriggers {
                let occursDuringEpisode = episodes.contains { episode in
                    trigger.timestamp >= episode.startDate && trigger.timestamp <= episode.endDate
                }
                
                if occursDuringEpisode {
                    withAf += 1
                } else {
                    withoutAf += 1
                }
            }
            
            correlations.append(TriggerCorrelation(
                triggerType: triggerType,
                occurrencesWithAf: withAf,
                occurrencesWithoutAf: withoutAf
            ))
        }
        
        return correlations
    }
    
    /// Analyze heart rate during AF episodes
    func analyzeHeartRateDuringEpisodes(
        episodes: [RhythmEpisode],
        heartRateReadings: [HeartRateReading]
    ) -> EpisodeHeartRateAnalysis {
        var avgHeartRates: [Double] = []
        var peakHeartRates: [Double] = []
        
        for episode in episodes {
            let episodeHR = heartRateReadings.filter { reading in
                reading.timestamp >= episode.startDate && reading.timestamp <= episode.endDate
            }
            
            if !episodeHR.isEmpty {
                let avg = episodeHR.map { Double($0.bpm) }.reduce(0, +) / Double(episodeHR.count)
                let peak = episodeHR.map { $0.bpm }.max() ?? 0
                
                avgHeartRates.append(avg)
                peakHeartRates.append(Double(peak))
            }
        }
        
        let overallAvg = avgHeartRates.isEmpty ? 0 : avgHeartRates.reduce(0, +) / Double(avgHeartRates.count)
        let overallPeak = peakHeartRates.max() ?? 0
        let unusualHighCount = peakHeartRates.filter { $0 > 150 }.count
        
        return EpisodeHeartRateAnalysis(
            averageHeartRate: overallAvg,
            peakHeartRate: overallPeak,
            episodesWithHighHR: unusualHighCount,
            totalEpisodesAnalyzed: episodes.count
        )
    }
}
