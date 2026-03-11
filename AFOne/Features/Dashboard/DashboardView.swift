import SwiftUI
import Charts

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCard

                    metricsSection

                    if !viewModel.recentEpisodes.isEmpty {
                        recentEpisodesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EmergencyView()) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable(action: refresh)
        }
        .task {
            await viewModel.loadData()
        }
    }

    private var statusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading) {
                    Text(viewModel.currentStatus.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.trend.icon)
                        Text(viewModel.trend.rawValue)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text("Last updated: \(viewModel.lastUpdated.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var statusIcon: String {
        switch viewModel.currentStatus {
        case .normal: return "heart.fill"
        case .af: return "heart.slash.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    private var statusColor: Color {
        switch viewModel.currentStatus {
        case .normal: return .green
        case .af: return .red
        case .unknown: return .gray
        }
    }

    private var metricsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                MetricCardView(
                    title: "AF Burden",
                    value: String(format: "%.1f%%", viewModel.afBurden),
                    icon: "waveform.path.ecg",
                    color: burdenColor
                )

                MetricCardView(
                    title: "Episodes",
                    value: "\(viewModel.episodeCount)",
                    subtitle: "Last 7 days",
                    icon: "heart.circle",
                    color: .red
                )

                MetricCardView(
                    title: "Avg HR",
                    value: "\(viewModel.averageHR)",
                    subtitle: "bpm",
                    icon: "heart",
                    color: .blue
                )
            }
        }
    }

    private var burdenColor: Color {
        if viewModel.afBurden < 1 { return .green }
        if viewModel.afBurden < 5 { return .yellow }
        if viewModel.afBurden < 20 { return .orange }
        return .red
    }

    private var recentEpisodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Episodes")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    EpisodeListView()
                }
                .font(.subheadline)
            }

            ForEach(viewModel.recentEpisodes) { episode in
                EpisodeRowView(episode: episode)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func refresh() {
        Task {
            await viewModel.loadData()
        }
    }
}

struct MetricCardView: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct EpisodeRowView: View {
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
                Text("bpm")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
