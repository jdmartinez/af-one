import SwiftData

enum SymptomType: String, CaseIterable, Codable {
    case palpitations = "Palpitations"
    case anxiety = "Anxiety"
    case dizziness = "Dizziness"
    case fatigue = "Fatigue"
    case shortnessOfBreath = "Shortness of Breath"
    case chestDiscomfort = "Chest Discomfort"
}

@Model
final class SymptomLog {
    var id: UUID
    var symptomType: String
    var timestamp: Date
    var notes: String?
    
    init(symptomType: SymptomType, timestamp: Date = .now, notes: String? = nil) {
        self.id = UUID()
        self.symptomType = symptomType.rawValue
        self.timestamp = timestamp
        self.notes = notes
    }
}
