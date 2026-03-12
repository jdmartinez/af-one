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
