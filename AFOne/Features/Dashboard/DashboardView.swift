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
            .navigationTitle("Resumen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationLink(destination: EmergencyView()) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color(.systemOrange))
                    }
                    .help("Open emergency information")
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            .sheet(isPresented: $showLogSheet) {
                LogView()
            }
        }
        .task {
            async let data: () = viewModel.loadData()
            async let burden: () = viewModel.loadBurden()
            _ = await (data, burden)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Sin datos de ritmo")
                .font(.headline)
            Text("Mantén el Apple Watch puesto para monitorizar tu ritmo cardíaco.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeroCardView(
                    isAFActive: viewModel.currentStatus == .af,
                    currentHR: viewModel.averageHR > 0 ? viewModel.averageHR : nil,
                    lastEpisodeDuration: nil,
                    episodesToday: viewModel.episodeCount,
                    confidenceLevel: "Alta confianza",
                    episodeStartDate: nil,
                    hasRecentEpisode: viewModel.hasRecentEpisode,
                    recentEpisodeEndDate: viewModel.recentEpisodeEndDate
                )
                
                SectionHeaderView(title: "AF BURDEN", showNavigationLink: false)
                burdenSection
                
                SectionHeaderView(title: "MAPA DE RITMO", showNavigationLink: false)
                RhythmMapView(hourlyData: viewModel.hourlyRhythmData)
                
                SectionHeaderView(title: "MÉTRICAS CLÍNICAS")
                ClinicalMetricsGridView(clinicalData: viewModel.clinicalMetricsData)

                SymptomCaptureButton(
                    showLogSheet: $showLogSheet,
                    isAFActive: viewModel.currentStatus == .af
                )
            }
            .padding(.horizontal, 16)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 34)
        }
    }

    // MARK: - Burden Section

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

    // MARK: - Helpers

    private var burdenTrendValue: Double {
        switch viewModel.burdenTrend {
        case .increasing: return 2.5
        case .decreasing: return -2.5
        case .stable: return 0.0
        }
    }

    private var statusColor: Color {
        switch viewModel.currentStatus {
        case .normal: return Color.afOne.rhythmSinusal
        case .af: return Color.afOne.rhythmAF
        case .unknown: return Color(.systemGray)
        }
    }
}

// MARK: - Supporting Views

struct SectionHeaderView: View {
    let title: String
    var showNavigationLink: Bool = false
    var navigationDestination: AnyView? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Spacer()
            if showNavigationLink, let destination = navigationDestination {
                NavigationLink(destination: destination) {
                    Text("Ver más")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 4)
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
                Text("FC: \(episode.averageHR)–\(episode.peakHR)")
                    .font(.caption)
                Text("lpm")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
