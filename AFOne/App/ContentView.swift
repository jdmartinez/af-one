import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "heart.text.square.fill")
                }
            
            EpisodeListView()
                .tabItem {
                    Label("Episodes", systemImage: "waveform.path.ecg")
                }
            
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "staroflife.fill")
                }
            
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
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
