import SwiftUI
import SwiftData

/// Main content view with GlassBottomBar tab navigation
struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var isTabBarVisible: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)
                
                TimelineView()
                    .tag(1)
                
                EpisodeListView()
                    .tag(2)
                
                MedicationsView()
                    .tag(3)
                
                AnalysisView()
                    .tag(4)
                
                TrendsView()
                    .tag(5)
                
                MoreView()
                    .tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // GlassBottomBar with collapse behavior
            if #available(iOS 26.0, *) {
                GlassBottomBar(
                    selectedTab: $selectedTab,
                    isVisible: isTabBarVisible
                )
                .opacity(isTabBarVisible ? 1 : 0)
                .offset(y: isTabBarVisible ? 0 : 100)
                .animation(.easeInOut(duration: 0.3), value: isTabBarVisible)
            } else {
                // Fallback for older iOS versions
                GlassBottomBar(
                    selectedTab: $selectedTab,
                    isVisible: isTabBarVisible
                )
                .opacity(isTabBarVisible ? 1 : 0)
                .offset(y: isTabBarVisible ? 0 : 100)
                .animation(.easeInOut(duration: 0.3), value: isTabBarVisible)
            }
        }
        .onChange(of: selectedTab) { _, _ in
            // Reset tab bar visibility when switching tabs
            withAnimation(.easeInOut(duration: 0.3)) {
                isTabBarVisible = true
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ContentView()
        .modelContainer(for: [SymptomLog.self, TriggerLog.self])
}
#endif
