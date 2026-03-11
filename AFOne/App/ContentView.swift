import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
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

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .tag(3)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    ContentView()
}
