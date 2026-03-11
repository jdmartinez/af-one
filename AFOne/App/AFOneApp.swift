import SwiftUI
import SwiftData

@main
struct AFOneApp: App {
    @State private var healthKitService = HealthKitService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitService)
        }
    }
}
