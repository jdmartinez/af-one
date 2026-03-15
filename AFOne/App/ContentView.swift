import SwiftUI
import SwiftData

/// Main content view
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "heart.text.square.fill") {
                DashboardView()
            }
            Tab("Episodes", systemImage: "waveform.path.ecg") {
                EpisodeListView()
            }
            Tab("Trends", systemImage: "chart.line.uptrend.xyaxis") {
                TrendsView()
            }
            Tab("Analysis", systemImage: "staroflife.fill") {
                AnalysisView()
            }
            Tab("More", systemImage: "ellipsis", role: .search) {
                MoreView()
            }
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
        .modelContainer(for: [SymptomLog.self, TriggerLog.self])
        .preferredColorScheme(.dark)
}
#endif
