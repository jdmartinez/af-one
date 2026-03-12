import SwiftUI

@Observable
@MainActor
class MedicationsViewModel {
    var medications: [MedicationInfo] = []
    var isLoading: Bool = false
    var error: String?
    var lastUpdated: Date?
    
    func loadMedications() async {
        isLoading = true
        error = nil
        
        do {
            medications = try await HealthKitService.shared.fetchMedications()
            lastUpdated = Date()
        } catch {
            self.error = "Unable to load medications. Please ensure you have added medications in the Health app."
        }
        
        isLoading = false
    }
}