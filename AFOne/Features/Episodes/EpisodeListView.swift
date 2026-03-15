import SwiftUI
import Charts

// MARK: - ViewModel

@MainActor
@Observable
final class EpisodeListViewModel {
    var episodes: [RhythmEpisode] = []
    var selectedFilter: EpisodeFilter = .all
    var isLoading = false

    enum EpisodeFilter: String, CaseIterable {
        case all = "Todos"
        case thisWeek = "Esta semana"
        case thisMonth = "Este mes"
    }

    var filteredEpisodes: [RhythmEpisode] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {
        case .all:
            return episodes
        case .thisWeek:
            return episodes.filter {
                calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear)
            }
        case .thisMonth:
            return episodes.filter {
                calendar.isDate($0.startDate, equalTo: now, toGranularity: .month)
            }
        }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let now = Date()
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            episodes = try await HealthKitService.shared.fetchEpisodes(from: monthAgo, to: now)
        } catch {
            episodes = [
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-7200), endDate: Date().addingTimeInterval(-3600), averageHR: 125, peakHR: 145, rhythmType: .af),
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-86400), endDate: Date().addingTimeInterval(-82800), averageHR: 110, peakHR: 132, rhythmType: .af),
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-172800), endDate: Date().addingTimeInterval(-169200), averageHR: 95, peakHR: 118, rhythmType: .af),
            ]
        }
    }
}

// MARK: - View

struct EpisodeListView: View {
    @State private var viewModel = EpisodeListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredEpisodes.isEmpty {
                    emptyStateView
                } else {
                    episodeList
                }
            }
            .navigationTitle("Episodios")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(viewModel.episodes.count) episodios")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Episode List

    private var episodeList: some View {
        List {
            Section {
                Picker("Filtro", selection: $viewModel.selectedFilter) {
                    ForEach(EpisodeListViewModel.EpisodeFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .padding(.vertical, 8)
            }

            Section {
                ForEach(viewModel.filteredEpisodes) { episode in
                    NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                        EpisodeRow(episode: episode)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Sin episodios")
                .font(.headline)
            Text("No se han encontrado episodios para el período seleccionado.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Episode Row

struct EpisodeRow: View {
    let episode: RhythmEpisode

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Text(episode.durationFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("FC: \(episode.averageHR)–\(episode.peakHR) lpm")
                    .font(.caption)
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.afOne.rhythmAF)
                        .frame(width: 8, height: 8)
                    Text("FA")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
