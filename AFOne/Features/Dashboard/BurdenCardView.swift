import SwiftUI

// MARK: - Burden Time Period
enum BurdenTimePeriod: String, CaseIterable, Identifiable {
    case day = "24h"
    case week = "7d"
    case month = "30d"
    
    var id: String { rawValue }
    
    /// Maps to TimePeriod for backend queries
    var timePeriod: TimePeriod {
        switch self {
        case .day: return .day
        case .week: return .week
        case .month: return .month
        }
    }
}

// MARK: - Burden Card View
struct BurdenCardView: View {
    let burdenPercentage: Double
    @Binding var selectedPeriod: BurdenTimePeriod
    let burdenTrend: Double
    let episodesToday: Int
    
    // MARK: - Layout Constants
    private let cardCornerRadius: CGFloat = 20
    private let cardPadding: CGFloat = 20
    private let screenMargin: CGFloat = 16
    private let progressBarHeight: CGFloat = 6
    private let tickMarkWidth: CGFloat = 2
    private let tickMarkHeight: CGFloat = 12
    
    // MARK: - Computed Properties
    private var burdenColor: Color {
        Color.afOne.burdenColor(for: burdenPercentage)
    }
    
    private var thresholdBadgeText: String {
        switch burdenPercentage {
        case ..<5.5:
            return "↓ ASSERT <5.5%"
        case 5.5..<11.0:
            return "5.5-10.9% ASSERT"
        default:
            return "≥11% Alto"
        }
    }
    
    private var thresholdCategory: String {
        switch burdenPercentage {
        case ..<5.5:
            return "Bajo riesgo"
        case 5.5..<11.0:
            return "Riesgo moderado"
        default:
            return "Alto riesgo"
        }
    }
    
    private var deltaText: String {
        let sign = burdenTrend >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", burdenTrend))% vs semana pasada"
    }
    
    private var deltaColor: Color {
        burdenTrend >= 0 ? Color.afOne.rhythmAF : Color.afOne.rhythmSinusal
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Time window selector
            timeWindowPicker
            
            // Primary value display
            primaryValueSection
            
            // Progress bar with threshold markers
            progressBarSection
            
            // Legend
            legendSection
            
            // Delta row
            deltaRow
        }
        .padding(cardPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AF Burden Card: \(String(format: "%.1f", burdenPercentage)) percent. \(thresholdCategory)")
    }
    
    // MARK: - Time Window Picker
    private var timeWindowPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(BurdenTimePeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Select time period for burden calculation")
    }
    
    // MARK: - Primary Value Section
    private var primaryValueSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            // Burden percentage value
            Text(String(format: "%.1f", burdenPercentage))
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(burdenColor)
                .accessibilityValue("\(String(format: "%.1f", burdenPercentage)) percent")
            
            // Percentage unit
            Text("%")
                .font(.title3)
                .foregroundStyle(.secondary)
                .baselineOffset(8)
            
            Spacer()
            
            // Threshold badge
            thresholdBadge
        }
    }
    
    // MARK: - Threshold Badge
    private var thresholdBadge: some View {
        Text(thresholdBadgeText)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(burdenColor.opacity(0.15), in: Capsule())
            .foregroundStyle(burdenColor.opacity(0.7))
            .accessibilityLabel("Risk category: \(thresholdCategory)")
    }
    
    // MARK: - Progress Bar Section
    private var progressBarSection: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width
            let fillWidth = min((burdenPercentage / 11.0) * maxWidth, maxWidth)
            let midPoint = maxWidth / 2
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemFill))
                    .frame(height: progressBarHeight)
                
                // Fill bar with gradient
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.afOne.burdenLow, burdenColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth, height: progressBarHeight)
                
                // Threshold tick marks
                // 50% position (5.5% burden)
                Rectangle()
                    .fill(Color.afOne.burdenMid.opacity(0.6))
                    .frame(width: tickMarkWidth, height: tickMarkHeight)
                    .position(x: midPoint, y: progressBarHeight / 2)
                
                // 100% position (11% burden)
                Rectangle()
                    .fill(Color.afOne.burdenHigh.opacity(0.6))
                    .frame(width: tickMarkWidth, height: tickMarkHeight)
                    .position(x: maxWidth, y: progressBarHeight / 2)
            }
        }
        .frame(height: tickMarkHeight)
        .accessibilityLabel("Burden progress: \(String(format: "%.1f", min(burdenPercentage, 11.0) / 11.0 * 100)) percent of maximum")
    }
    
    // MARK: - Legend Section
    private var legendSection: some View {
        HStack(spacing: 16) {
            // Bajo riesgo (low)
            Label {
                Text("Bajo riesgo")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } icon: {
                Circle()
                    .fill(Color.afOne.burdenLow)
                    .frame(width: 8, height: 8)
            }
            
            Spacer()
            
            // >= 5.5% ASSERT (mid)
            Label {
                Text("≥5.5% ASSERT")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } icon: {
                Circle()
                    .fill(Color.afOne.burdenMid)
                    .frame(width: 8, height: 8)
            }
            
            Spacer()
            
            // >= 11% Alto (high)
            Label {
                Text("≥11% Alto")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } icon: {
                Circle()
                    .fill(Color.afOne.burdenHigh)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    // MARK: - Delta Row
    private var deltaRow: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                // Delta vs last week
                HStack(spacing: 4) {
                    Image(systemName: burdenTrend >= 0 ? "arrow.up" : "arrow.down")
                    Text(deltaText)
                }
                .font(.caption)
                .foregroundStyle(deltaColor)
                
                Spacer()
                
                // Episodes today
                Text("\(episodesToday) episodios hoy")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Low burden
        BurdenCardView(
            burdenPercentage: 3.2,
            selectedPeriod: .constant(.week),
            burdenTrend: -1.5,
            episodesToday: 1
        )
        
        // Mid burden
        BurdenCardView(
            burdenPercentage: 7.8,
            selectedPeriod: .constant(.week),
            burdenTrend: 2.3,
            episodesToday: 3
        )
        
        // High burden
        BurdenCardView(
            burdenPercentage: 14.5,
            selectedPeriod: .constant(.week),
            burdenTrend: 5.2,
            episodesToday: 5
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
