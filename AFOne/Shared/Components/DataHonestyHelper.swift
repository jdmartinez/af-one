import SwiftUI

// MARK: - Data Honesty Helper
/// Provides reusable formatting helpers for consistent data honesty messaging.
/// Per DATA-01 through DATA-05 requirements — ensures users understand which values
/// are estimates vs. direct measurements from Apple Watch.
enum DataHonestyHelper {
    /// Formats SpO2 value, returns "Sin dato" if nil/0
    /// Per DATA-02: Never show out-of-window value as 0%
    static func formatSpO2(_ value: Int?) -> String {
        if let value = value, value > 0 {
            return "\(value)%"
        } else {
            return "Sin dato"
        }
    }

    /// Formats estimated value with "est." suffix
    static func formatEstimatedValue<T: CustomStringConvertible>(_ value: T) -> String {
        "\(value) (est.)"
    }

    /// Standard disclosure text for episode timer
    /// Per DATA-03: Timer from last Apple Watch data point
    static let timerDisclosureText = "Desde último dato de Apple Watch"

    /// Standard note for user-declared data
    /// Per DATA-04: Patient self-reported information
    static let userDeclaredNote = "Declarada por el paciente"

    /// Format SpO2 chip for episode rows
    /// Shows styled chip with "Sin dato" when value is nil/0
    @ViewBuilder
    static func spo2Chip(_ value: Int?) -> some View {
        if let value = value, value > 0 {
            Text("SpO2 \(value)%")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.2))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
        } else {
            Text("SpO2 Sin dato")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.secondary.opacity(0.1))
                .foregroundStyle(.secondary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - User Declared Badge
/// Badge component for marking user-declared data
struct UserDeclaredBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.fill.questionmark")
                .font(.caption2)
            Text("Declarada por el paciente")
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
        .padding(.top, 8)
    }
}
