import SwiftUI
import SwiftData

@main
struct AFOneApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var healthKitService = HealthKitService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(healthKitService)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task {
                            await NotificationService.shared.checkForLongEpisodes()
                            await NotificationService.shared.checkForBurdenIncrease()
                        }
                    }
                }
        }
        .modelContainer(for: [SymptomLog.self, TriggerLog.self])
    }
}
