import Foundation

struct HeartRateReading: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let bpm: Int
    let source: String
}
