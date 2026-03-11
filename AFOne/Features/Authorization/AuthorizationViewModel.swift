import SwiftUI

@MainActor
@Observable
final class AuthorizationViewModel {
    var isLoading = false
    var authorizationStatus: AuthorizationStatus = .notDetermined
    var errorMessage: String?
    var hasCompletedOnboarding: Bool = false

    enum AuthorizationStatus {
        case notDetermined
        case authorized
        case denied
    }

    init() {
        checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func requestAuthorization() async {
        isLoading = true
        errorMessage = nil

        do {
            let success = try await HealthKitService.shared.requestAuthorization()
            if success {
                authorizationStatus = .authorized
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                hasCompletedOnboarding = true
            } else {
                authorizationStatus = .denied
                errorMessage = "Authorization was not granted. Please enable access in Settings."
            }
        } catch {
            authorizationStatus = .denied
            errorMessage = "Failed to request authorization: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
