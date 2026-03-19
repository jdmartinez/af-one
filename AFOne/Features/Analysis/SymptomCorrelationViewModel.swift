import Foundation
import SwiftUI
import SwiftData

enum CorrelationPeriod: String, CaseIterable, Identifiable {
    case day = "Hoy"
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

struct PatternInfo: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let clinicalNote: String
    var isExpanded: Bool
}

enum CorrelationFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case withAF = "Con FA"
    case withoutAF = "Sin FA"
    case silentAF = "FA silente"

    var id: String { rawValue }
}

@MainActor
@Observable
final class SymptomCorrelationViewModel {
    var selectedPeriod: CorrelationPeriod = .week
    var summary: CorrelationSummary = .empty
    var correlationItems: [CorrelationItem] = []
    var filteredItems: [CorrelationItem] = []
    var detectedPatterns: [PatternInfo] = []
    var isLoading = false
    var selectedFilter: CorrelationFilter = .all
    var selectedItem: CorrelationItem?
    var showDetailSheet = false

    private let analyzer = CorrelationAnalyzer()
    private var allSymptoms: [SymptomLog] = []
    private var allEpisodes: [RhythmEpisode] = []

    var symptomsWithAfCount: Int { summary.symptomsWithAf }
    var symptomsWithoutAfCount: Int { summary.symptomsWithoutAf }
    var silentAfCount: Int { summary.silentAfEpisodeCount }

    var activeFilterColor: CorrelationType? {
        switch selectedFilter {
        case .withAF: return .faConfirmed
        case .withoutAF: return .noCorrelation
        case .silentAF: return .silentAF
        case .all: return nil
        }
    }

    func loadData(symptoms: [SymptomLog], episodes: [RhythmEpisode]) async {
        isLoading = true
        allSymptoms = symptoms
        allEpisodes = episodes

        let windowResult = await analyzer.analyzeWithWindow(
            symptoms: symptoms,
            episodes: episodes
        )
        summary = windowResult

        let items = await analyzer.correlationItems(
            symptoms: symptoms,
            episodes: episodes
        )
        correlationItems = items
        applyFilter()

        await detectPatterns()

        isLoading = false
    }

    private func applyFilter() {
        switch selectedFilter {
        case .all:
            filteredItems = correlationItems
        case .withAF:
            filteredItems = correlationItems.filter { $0.correlationType == .faConfirmed }
        case .withoutAF:
            filteredItems = correlationItems.filter { $0.correlationType == .noCorrelation }
        case .silentAF:
            filteredItems = correlationItems.filter { $0.correlationType == .silentAF }
        }
    }

    func setFilter(_ filter: CorrelationFilter) {
        selectedFilter = filter
        applyFilter()
    }

    private func detectPatterns() async {
        let nocturnal = await analyzer.detectNocturnalSymptomsWithoutAF(
            symptoms: allSymptoms,
            episodes: allEpisodes
        )
        let preceding = await analyzer.detectSymptomsPrecedingAF(
            symptoms: allSymptoms,
            episodes: allEpisodes
        )

        var patterns: [PatternInfo] = []

        if nocturnal > 0 {
            patterns.append(PatternInfo(
                name: "Síntomas nocturnos sin FA",
                count: nocturnal,
                clinicalNote: "Síntomas nocturnos sin FA — pueden tener causas no relacionadas con arritmia",
                isExpanded: false
            ))
        }

        if preceding > 0 {
            patterns.append(PatternInfo(
                name: "Síntomas previos a FA",
                count: preceding,
                clinicalNote: "Síntomas previos a FA — pueden ser señales de aviso",
                isExpanded: false
            ))
        }

        if summary.silentAfEpisodeCount > 0 {
            patterns.append(PatternInfo(
                name: "FA silente",
                count: summary.silentAfEpisodeCount,
                clinicalNote: "FA silente: episodios de FA sin síntomas reportados — considere revisar su registro de síntomas",
                isExpanded: false
            ))
        }

        detectedPatterns = patterns
    }

    func selectItem(_ item: CorrelationItem) {
        selectedItem = item
        showDetailSheet = true
    }
}
