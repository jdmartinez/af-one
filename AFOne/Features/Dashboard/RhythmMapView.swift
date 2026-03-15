import SwiftUI

// MARK: - Hourly Rhythm Data Model
struct HourlyRhythmData: Identifiable {
    let id = UUID()
    let hour: Int // 0-23
    let rhythmClassification: RhythmClassification
    let sampleCount: Int
    let averageHeartRate: Int?
    
    /// Hour range string (e.g., "00:00 - 01:00")
    var hourRangeText: String {
        let nextHour = (hour + 1) % 24
        return String(format: "%02d:00 - %02d:00", hour, nextHour)
    }
    
    /// Short hour label (e.g., "00:00")
    var hourLabel: String {
        String(format: "%02d:00", hour)
    }
}

// MARK: - Rhythm Classification
enum RhythmClassification: String, Codable {
    case sinusRhythm = "SR"
    case atrialFibrillation = "AF"
    case noData = "NoData"
    
    var displayName: String {
        switch self {
        case .sinusRhythm:
            return "Ritmo sinusal"
        case .atrialFibrillation:
            return "Fibrilación auricular"
        case .noData:
            return "Sin datos"
        }
    }
}

// MARK: - Top-Rounded Rectangle Shape
struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at bottom-left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Line to bottom-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Line to top-right (start of curve)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius))
        
        // Top-right corner (clockwise)
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        
        // Line to top-left (start of curve)
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        
        // Top-left corner (clockwise)
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        
        // Close path
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

// MARK: - Rhythm Map View
struct RhythmMapView: View {
    let hourlyData: [HourlyRhythmData]
    
    // MARK: - Layout Constants
    private let cardCornerRadius: CGFloat = 20
    private let cardPadding: CGFloat = 20
    private let barSpacing: CGFloat = 2
    private let maxBarHeight: CGFloat = 36
    private let minBarHeight: CGFloat = 4
    private let maxExpectedHR: CGFloat = 180 // Max reasonable HR for height calculation
    
    // MARK: - State
    @State private var selectedHour: Int?
    @State private var showPopover: Bool = false
    
    // MARK: - Computed Properties
    private var averageHeartRate: Int {
        let validRates = hourlyData.compactMap { $0.averageHeartRate }
        guard !validRates.isEmpty else { return 0 }
        return validRates.reduce(0, +) / validRates.count
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            headerSection
            
            // Bar chart
            barChartSection
            
            // Time axis
            timeAxisSection
            
            Divider()
                .padding(.top, 4)
            
            // Legend
            legendSection
        }
        .padding(cardPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("24-hour rhythm map showing hourly heart rhythm classifications")
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("RHYTHM MAP")
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.tertiary)
            
            Spacer()
            
            Text("24h")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Bar Chart Section
    private var barChartSection: some View {
        HStack(alignment: .bottom, spacing: barSpacing) {
            ForEach(hourlyData) { data in
                barView(for: data)
            }
        }
        .frame(height: maxBarHeight)
    }
    
    // MARK: - Individual Bar View
    @ViewBuilder
    private func barView(for data: HourlyRhythmData) -> some View {
        let barHeight: CGFloat = {
            if data.rhythmClassification == .noData {
                return minBarHeight
            } else if let hr = data.averageHeartRate, hr > 0 {
                return max(minBarHeight, (CGFloat(hr) / maxExpectedHR) * maxBarHeight)
            } else {
                return minBarHeight
            }
        }()
        
        let barColor: Color
        let opacity: Double
        
        switch data.rhythmClassification {
        case .sinusRhythm:
            barColor = Color(.systemBlue)
            opacity = data.sampleCount < 3 ? 0.4 : 0.5
        case .atrialFibrillation:
            barColor = Color.afOne.rhythmAF
            opacity = data.sampleCount < 3 ? 0.4 : 0.9
        case .noData:
            barColor = Color(.systemFill)
            opacity = 1.0
        }
        
        return VStack(spacing: 0) {
            Spacer()
            
            TopRoundedRectangle(cornerRadius: 3)
                .fill(barColor.opacity(opacity))
                .frame(height: barHeight)
                .frame(maxWidth: .infinity)
        }
        .frame(height: maxBarHeight)
        .onTapGesture {
            selectedHour = data.hour
            showPopover = true
        }
        .popover(isPresented: $showPopover, arrowEdge: .top) {
            popoverContent(for: data)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(data.hourLabel): \(data.rhythmClassification.displayName). \(data.sampleCount) samples")
        .accessibilityHint("Tap for details")
    }
    
    // MARK: - Popover Content
    private func popoverContent(for data: HourlyRhythmData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Hour range
            Text(data.hourRangeText)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Divider()
            
            // Classification
            HStack {
                Circle()
                    .fill(colorForClassification(data.rhythmClassification))
                    .frame(width: 10, height: 10)
                Text(data.rhythmClassification.displayName)
                    .font(.caption)
            }
            
            // Sample count
            Text("\(data.sampleCount) lecturas de FC")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Warning for insufficient data
            if data.sampleCount < 3 {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text("Datos insuficientes — clasificación estimada")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }
    
    // MARK: - Time Axis Section
    private var timeAxisSection: some View {
        HStack(alignment: .top) {
            ForEach([0, 6, 12, 18, 23], id: \.self) { hour in
                Text(String(format: "%02d:00", hour))
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
                
                if hour != 23 {
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Legend Section
    private var legendSection: some View {
        HStack(spacing: 16) {
            // Sinus rhythm
            legendItem(
                color: Color(.systemBlue).opacity(0.5),
                label: "Ritmo sinusal"
            )
            
            Spacer()
            
            // Atrial fibrillation
            legendItem(
                color: Color.afOne.rhythmAF.opacity(0.9),
                label: "Fibrilación auricular"
            )
            
            Spacer()
            
            // No data
            legendItem(
                color: Color(.systemFill),
                label: "Sin datos"
            )
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helper Functions
    private func colorForClassification(_ classification: RhythmClassification) -> Color {
        switch classification {
        case .sinusRhythm:
            return Color(.systemBlue).opacity(0.5)
        case .atrialFibrillation:
            return Color.afOne.rhythmAF.opacity(0.9)
        case .noData:
            return Color(.systemFill)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleData: [HourlyRhythmData] = (0..<24).map { hour in
        let classification: RhythmClassification
        let sampleCount: Int
        let hr: Int?
        
        switch hour {
        case 0...5:
            classification = .noData
            sampleCount = 0
            hr = nil
        case 6...8:
            classification = .sinusRhythm
            sampleCount = 8
            hr = 65
        case 9...11:
            classification = .sinusRhythm
            sampleCount = 2 // Low sample warning
            hr = 72
        case 12...14:
            classification = .atrialFibrillation
            sampleCount = 10
            hr = 120
        case 15...17:
            classification = .atrialFibrillation
            sampleCount = 1 // Low sample warning
            hr = 110
        case 18...20:
            classification = .sinusRhythm
            sampleCount = 7
            hr = 80
        default:
            classification = .noData
            sampleCount = 0
            hr = nil
        }
        
        return HourlyRhythmData(
            hour: hour,
            rhythmClassification: classification,
            sampleCount: sampleCount,
            averageHeartRate: hr
        )
    }
    
    return RhythmMapView(hourlyData: sampleData)
        .padding()
}
