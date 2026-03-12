import SwiftUI
import Charts

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var showLogSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        statusCard

                        metricsSection

                        burdenSection

                        if !viewModel.recentEpisodes.isEmpty {
                            recentEpisodesSection
                        }
                    }
                    .padding()
                }
            
            VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showLogSheet = true }) {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
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
            .sheet(isPresented: $showLogSheet) {
                LogView()
            }
        }
        .task {
            await viewModel.loadData()
            await viewModel.loadBurden()
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

    private var burdenSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AF Burden")
                    .font(.headline)
                
                Spacer()
                
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(TimePeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .onChange(of: viewModel.selectedPeriod) { _, _ in
                    Task {
                        await viewModel.loadBurden()
                    }
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", viewModel.currentBurden))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                Text("%")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: viewModel.burdenTrendIcon)
                    Text(viewModel.burdenTrend.description)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            if !viewModel.burdenData.isEmpty {
                BurdenChartView(data: viewModel.burdenData, period: viewModel.selectedPeriod)
                    .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
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
