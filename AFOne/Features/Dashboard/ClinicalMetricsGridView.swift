import SwiftUI

// MARK: - Clinical Metrics Data Model

struct ClinicalMetricsData {
    /// SpO₂ reading during current episode (nil if no coincident reading within ±15 min)
    var spo2DuringEpisode: Double?
    
    /// HRV during sinus rhythm windows (in milliseconds)
    var hrvDuringSR: Double?
    
    /// Ventricular response during AF (nil if no AF today)
    var ventricularResponseAF: Int?
    
    /// Duration of current episode
    var currentEpisodeDuration: TimeInterval?
    
    /// Onset date of current episode
    var episodeOnsetDate: Date?
    
    /// Count of symptoms without explanatory rhythm
    var unmatchedSymptomCount: Int
    
    /// Most recent unmatched symptom capture date
    var mostRecentUnmatchedDate: Date?
}

// MARK: - Clinical Metrics Grid View

struct ClinicalMetricsGridView: View {
    let clinicalData: ClinicalMetricsData
    
    /// Columns for the LazyVGrid (2 columns, 10pt spacing)
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            // SpO₂ during episode card
            spo2Card
            
            // HRV during SR card
            hrvCard
            
            // Ventricular response AF card
            ventricularResponseCard
            
            // Episode duration card
            episodeDurationCard
            
            // Wide card - Unmatched symptoms
            unmatchedSymptomsCard
                .gridCellColumns(2)
        }
        .padding(16)
    }
    
    // MARK: - SpO₂ During Episode Card
    
    private var spo2Card: some View {
        MetricCard(
            icon: "lungs.fill",
            label: "SpO₂ EN EPISODIO",
            value: spo2Value,
            unit: spo2Unit,
            subLabel: spo2SubLabel
        )
    }
    
    private var spo2Value: String {
        if let spo2 = clinicalData.spo2DuringEpisode {
            return String(format: "%.0f", spo2)
        }
        return "No data"
    }
    
    private var spo2Unit: String? {
        if clinicalData.spo2DuringEpisode != nil {
            return "%"
        }
        return nil
    }
    
    private var spo2SubLabel: String? {
        if clinicalData.spo2DuringEpisode != nil {
            return "Durante episodio"
        }
        return "No datos durante el episodio"
    }
    
    // MARK: - HRV Card
    
    private var hrvCard: some View {
        MetricCard(
            icon: "waveform.path.ecg",
            label: "HRV (EN RS)",
            value: hrvValue,
            unit: hrvUnit,
            subLabel: hrvSubLabel,
            showEstSuffix: clinicalData.hrvDuringSR != nil
        )
    }
    
    private var hrvValue: String {
        if let hrv = clinicalData.hrvDuringSR {
            return String(format: "%.0f", hrv)
        }
        return "—"
    }
    
    private var hrvUnit: String? {
        if clinicalData.hrvDuringSR != nil {
            return "ms"
        }
        return nil
    }
    
    private var hrvSubLabel: String? {
        if clinicalData.hrvDuringSR != nil {
            return "Estimado"
        }
        return nil
    }
    
    // MARK: - Ventricular Response AF Card
    
    private var ventricularResponseCard: some View {
        MetricCard(
            icon: "bolt.heart.fill",
            label: "RESP. VENTRICULAR AF",
            value: ventricularResponseValue,
            unit: ventricularResponseUnit,
            subLabel: ventricularResponseSubLabel,
            showEstSuffix: clinicalData.ventricularResponseAF != nil
        )
    }
    
    private var ventricularResponseValue: String {
        if let vr = clinicalData.ventricularResponseAF {
            return "\(vr)"
        }
        return "—"
    }
    
    private var ventricularResponseUnit: String? {
        if clinicalData.ventricularResponseAF != nil {
            return "lpm"
        }
        return nil
    }
    
    private var ventricularResponseSubLabel: String? {
        if clinicalData.ventricularResponseAF != nil {
            return "Estimado"
        }
        return "Sin AF hoy"
    }
    
    // MARK: - Episode Duration Card
    
    private var episodeDurationCard: some View {
        MetricCard(
            icon: "clock.fill",
            label: "DURACIÓN EP.",
            value: episodeDurationValue,
            unit: nil,
            subLabel: episodeDurationSubLabel
        )
    }
    
    private var episodeDurationValue: String {
        if let duration = clinicalData.currentEpisodeDuration {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
        return "—"
    }
    
    private var episodeDurationSubLabel: String? {
        if let onsetDate = clinicalData.episodeOnsetDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Desde \(formatter.string(from: onsetDate))"
        }
        return nil
    }
    
    // MARK: - Unmatched Symptoms Wide Card
    
    private var unmatchedSymptomsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon and label
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Text("SÍNTOMAS SIN RITMO EXPLICATIVO")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
            }
            
            // Value
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(clinicalData.unmatchedSymptomCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            // Sub-label with timestamp and action button
            if let recentDate = clinicalData.mostRecentUnmatchedDate {
                HStack {
                    Text(formattedDate(recentDate))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    Button("Ver correlación →") {
                        // Action: Navigate to symptom correlation view
                    }
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                }
            } else {
                HStack {
                    Text("Sin síntomas registrados")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(unmatchedSymptomsAccessibilityLabel)
    }
    
    private var unmatchedSymptomsAccessibilityLabel: String {
        let count = clinicalData.unmatchedSymptomCount
        let label = count == 1 ? "síntoma sin ritmo explicativo" : "síntomas sin ritmo explicativo"
        let dateText = clinicalData.mostRecentUnmatchedDate.map { "Más reciente: \(formattedDate($0))" } ?? "Sin síntomas registrados"
        return "\(count) \(label). \(dateText)"
    }
    
    // MARK: - Helpers
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Metric Card Component

struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let unit: String?
    let subLabel: String?
    var showEstSuffix: Bool = false
    
    @ScaledMetric private var iconSize: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon and label row
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: iconSize, height: iconSize)
                
                Text(label)
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
            }
            
            // Value with optional unit
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if let unit = unit {
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if showEstSuffix {
                    Text("est.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Sub-label
            if let subLabel = subLabel {
                Text(subLabel)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabelText: String {
        var label = "\(label): \(value)"
        if let unit = unit {
            label += " \(unit)"
        }
        if showEstSuffix {
            label += " estimado"
        }
        if let subLabel = subLabel {
            label += ". \(subLabel)"
        }
        return label
    }
}

// MARK: - Preview

#Preview {
    ClinicalMetricsGridView(
        clinicalData: ClinicalMetricsData(
            spo2DuringEpisode: 97,
            hrvDuringSR: 45,
            ventricularResponseAF: 112,
            currentEpisodeDuration: 3600,
            episodeOnsetDate: Date().addingTimeInterval(-3600),
            unmatchedSymptomCount: 3,
            mostRecentUnmatchedDate: Date().addingTimeInterval(-7200)
        )
    )
    .preferredColorScheme(.dark)
}
