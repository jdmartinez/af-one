import Foundation

/// RhythmEpisode - Represents an AF episode detected by Apple Watch
struct RhythmEpisode: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let averageHR: Int
    let peakHR: Int
    let rhythmType: RhythmType

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var durationFormatted: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

/// RhythmType - Type of rhythm detected
enum RhythmType: String, Codable {
    case normal
    case af = "AF"
    case unknown
}
