import SwiftUI
import SwiftData

@Observable
@MainActor
class LogViewModel {
    var selectedSymptoms: Set<SymptomType> = []
    var selectedTriggers: Set<TriggerType> = []
    var notes: String = ""
    var isSaving: Bool = false
    var saveError: String?
    
    private var modelContext: ModelContext?
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var canSave: Bool {
        !selectedSymptoms.isEmpty || !selectedTriggers.isEmpty
    }
    
    func saveLogs() {
        guard canSave, let modelContext else { return }
        
        isSaving = true
        saveError = nil
        
        let timestamp = Date()
        
        // Save symptoms
        for symptomType in selectedSymptoms {
            let symptomLog = SymptomLog(symptomType: symptomType, timestamp: timestamp, notes: notes.isEmpty ? nil : notes)
            modelContext.insert(symptomLog)
        }
        
        // Save triggers
        for triggerType in selectedTriggers {
            let triggerLog = TriggerLog(triggerType: triggerType, timestamp: timestamp, notes: notes.isEmpty ? nil : notes)
            modelContext.insert(triggerLog)
        }
        
        do {
            try modelContext.save()
            reset()
        } catch {
            saveError = "Failed to save: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
    
    func reset() {
        selectedSymptoms = []
        selectedTriggers = []
        notes = ""
    }
}
