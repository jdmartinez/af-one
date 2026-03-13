import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isAuthorized: Bool? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if let authorized = isAuthorized {
                if authorized {
                    mainTabView
                } else {
                    AuthorizationView {
                        isAuthorized = true
                    }
                }
            } else {
                ProgressView("Checking HealthKit...")
                    .task {
                        await checkAuthorization()
                    }
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "chart.bar.xaxis")
                }
                .tag(1)

            EpisodeListView()
                .tabItem {
                    Label("Episodes", systemImage: "heart.circle")
                }
                .tag(2)

            MedicationsView()
                .tabItem {
                    Label("Medications", systemImage: "pills")
                }
                .tag(3)

            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(4)

            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(5)

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .tag(6)
        }
        .tabViewStyle(.automatic)
    }
    
    private func checkAuthorization() async {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
        let status = HKHealthStore().authorizationStatus(for: heartRateType!)
        
        if status == .sharingAuthorized {
            isAuthorized = true
        } else {
            isAuthorized = false
        }
    }
}

#Preview {
    ContentView()
}
