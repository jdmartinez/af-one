import SwiftUI
import Charts

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var showLogSheet = false
    @State private var selectedBurdenPeriod: BurdenTimePeriod = .week

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.dataEmpty {
                    emptyStateView
                } else {
                    dashboardContent
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EmergencyView()) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color(.systemOrange))
                    }
                    .help("Open emergency information")
                }
            }
            .refreshable {
                let viewModel = self.viewModel
                Task { @MainActor in
                    await viewModel.loadData()
                }
            }
            .sheet(isPresented: $showLogSheet) {
                LogView()
            }
        }
        .task {
            await viewModel.loadData()
            await viewModel.loadBurden()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading dashboard...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Heart Data Yet")
                .font(.headline)
            
            Text("Keep your Apple Watch on to monitor your heart rhythm.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var dashboardContent: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Zone 1 - Hero Card
                    HeroCardView(
                        isAFActive: viewModel.currentStatus == .af,
                        currentHR: viewModel.averageHR > 0 ? viewModel.averageHR : nil,
                        lastEpisodeDuration: nil,
                        episodesToday: viewModel.episodeCount,
                        confidenceLevel: "Alta confianza",
                        episodeStartDate: nil
                    )
                    
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        case .normal: return Color.afOne.rhythmSinusal
        case .af: return Color.afOne.rhythmAF
        case .unknown: return Color(.systemGray)
        }
    }

    private var metricsSection: some View {
        LazyVStack(spacing: 12) {
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
                color: Color.afOne.rhythmAF
            )
            
            MetricCardView(
                title: "Avg HR",
                value: "\(viewModel.averageHR)",
                subtitle: "bpm",
                icon: "heart",
                color: Color(.systemBlue)
            )
            
            MetricCardView(
                title: "Status",
                value: viewModel.currentStatus.rawValue,
                subtitle: viewModel.trend.rawValue,
                icon: viewModel.statusIcon,
                color: statusColor
            )
        }
    }

    private var burdenSection: some View {
        BurdenCardView(
            burdenPercentage: viewModel.currentBurden,
            selectedPeriod: $selectedBurdenPeriod,
            burdenTrend: burdenTrendValue,
            episodesToday: viewModel.episodeCount
        )
        .onChange(of: selectedBurdenPeriod) { _, newValue in
            Task {
                viewModel.selectedPeriod = newValue.timePeriod
                await viewModel.loadBurden()
            }
        }
    }
    
    private var burdenTrendValue: Double {
        switch viewModel.burdenTrend {
        case .increasing: return 2.5
        case .decreasing: return -2.5
        case .stable: return 0.0
        }
    }

    private var burdenColor: Color {
        return Color.afOne.burdenColor(for: viewModel.afBurden)
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func refresh() {
        Task { @MainActor in
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
            // Header: colored circle icon + title on left, value on right
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 10, height: 10)
                        Image(systemName: icon)
                            .font(.system(size: 6))
                            .foregroundStyle(.white)
                    }
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 34, weight: .bold))
            }
            
            // Optional subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
