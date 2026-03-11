import SwiftData

enum TriggerType: String, CaseIterable, Codable {
    case alcohol = "Alcohol"
    case caffeine = "Caffeine"
    case stress = "Stress"
    case poorSleep = "Poor Sleep"
    case heavyMeals = "Heavy Meals"
    case intenseExercise = "Intense Exercise"
}

@Model
final class TriggerLog {
    var id: UUID
    var triggerType: String
    var timestamp: Date
    var intensity: String?
    var notes: String?
    
    init(triggerType: TriggerType, timestamp: Date = .now, intensity: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.triggerType = triggerType.rawValue
        self.timestamp = timestamp
        self.intensity = intensity
        self.notes = notes
    }
}
