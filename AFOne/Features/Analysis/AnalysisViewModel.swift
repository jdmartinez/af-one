import SwiftUI
import SwiftData

/// AnalysisViewModel - ViewModel for analysis view with correlation data
@Observable
@MainActor
class AnalysisViewModel {
    var correlationResult: CorrelationResult?
    var symptomBreakdown: [SymptomCorrelation] = []
    var triggerBreakdown: [TriggerCorrelation] = []
    var hrAnalysis: EpisodeHeartRateAnalysis?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private var modelContext: ModelContext?
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadAnalysis() async {
        guard let modelContext else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch recent episodes (last 30 days)
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            let episodes = try await HealthKitService.shared.fetchEpisodes(from: thirtyDaysAgo, to: Date())
            
            // Fetch symptoms from SwiftData
            let symptomDescriptor = FetchDescriptor<SymptomLog>(
                predicate: #Predicate { $0.timestamp >= thirtyDaysAgo },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let symptoms = try modelContext.fetch(symptomDescriptor)
            
            // Fetch triggers from SwiftData
            let triggerDescriptor = FetchDescriptor<TriggerLog>(
                predicate: #Predicate { $0.timestamp >= thirtyDaysAgo },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let triggers = try modelContext.fetch(triggerDescriptor)
            
            // Analyze correlation
            let analyzer = CorrelationAnalyzer()
            correlationResult = await analyzer.analyzeCorrelation(symptoms: symptoms, episodes: episodes)
            symptomBreakdown = await analyzer.analyzeSymptomBreakdown(symptoms: symptoms, episodes: episodes)
            triggerBreakdown = await analyzer.analyzeTriggerBreakdown(triggers: triggers, episodes: episodes)
            
            // Analyze heart rate
            let heartRateReadings = try await HealthKitService.shared.fetchHeartRateSamples(
                from: thirtyDaysAgo,
                to: Date()
            )
            hrAnalysis = await analyzer.analyzeHeartRateDuringEpisodes(
                episodes: episodes,
                heartRateReadings: heartRateReadings
            )
        } catch {
            errorMessage = "Failed to load analysis: \(error.localizedDescription)"
            print("Failed to load analysis: \(error)")
        }
        
        isLoading = false
    }
}
