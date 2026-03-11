import SwiftUI
import Charts

@MainActor
@Observable
final class EpisodeListViewModel {
    var episodes: [RhythmEpisode] = []
    var selectedFilter: EpisodeFilter = .all
    var isLoading = false

    enum EpisodeFilter: String, CaseIterable {
        case all = "All"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }

    var filteredEpisodes: [RhythmEpisode] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedFilter {
        case .all:
            return episodes
        case .thisWeek:
            return episodes.filter { episode in
                calendar.isDate(episode.startDate, equalTo: now, toGranularity: .weekOfYear)
            }
        case .thisMonth:
            return episodes.filter { episode in
                calendar.isDate(episode.startDate, equalTo: now, toGranularity: .month)
            }
        }
    }

    func loadData() async {
        isLoading = true

        do {
            let now = Date()
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            episodes = try await HealthKitService.shared.fetchEpisodes(from: monthAgo, to: now)
        } catch {
            // Sample data
            episodes = [
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-7200), endDate: Date().addingTimeInterval(-3600), averageHR: 125, peakHR: 145, rhythmType: .af),
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-86400), endDate: Date().addingTimeInterval(-82800), averageHR: 110, peakHR: 132, rhythmType: .af),
                RhythmEpisode(id: UUID(), startDate: Date().addingTimeInterval(-172800), endDate: Date().addingTimeInterval(-169200), averageHR: 95, peakHR: 118, rhythmType: .af),
            ]
        }

        isLoading = false
    }
}

struct EpisodeListView: View {
    @State private var viewModel = EpisodeListViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(EpisodeListViewModel.EpisodeFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.filteredEpisodes.isEmpty {
                    Spacer()
                    Text("No episodes found")
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredEpisodes) { episode in
                            NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                EpisodeRow(episode: episode)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Episodes")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(viewModel.episodes.count) episodes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .refreshable(action: refresh)
        }
        .task {
            await viewModel.loadData()
        }
    }

    private func refresh() async {
        await viewModel.loadData()
    }
}

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
                Text("HR: \(episode.averageHR)-\(episode.peakHR)")
                    .font(.caption)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("AF")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
