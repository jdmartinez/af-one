import SwiftUI

enum BurdenLevel: String {
    case low = "Bajo"
    case medium = "Medio"
    case high = "Alto"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct ThresholdBadge: View {
    let level: BurdenLevel
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(level.color)
                .frame(width: 8, height: 8)
            Text(level.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(level.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(level.color.opacity(0.15))
        .clipShape(Capsule())
    }
}

struct ClinicalReferenceBadge: View {
    let level: BurdenLevel
    
    private var reference: String {
        switch level {
        case .low: return "ASSERT <5.5%"
        case .medium: return "ASSERT ≥5.5%"
        case .high: return "TRENDS ≥11%"
        }
    }
    
    var body: some View {
        Text(reference)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct BurdenProgressBar: View {
    let percentage: Double
    let level: BurdenLevel
    
    private let lowThreshold: Double = 5.5
    private let highThreshold: Double = 11.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.15))
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [level.color.opacity(0.7), level.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(percentage / 100, 1.0))
                
                ForEach([lowThreshold, highThreshold], id: \.self) { threshold in
                    Rectangle()
                        .fill(Color.primary.opacity(0.3))
                        .frame(width: 2)
                        .offset(x: geometry.size.width * (threshold / 100))
                }
            }
        }
        .frame(height: 16)
    }
}

struct DeltaRow: View {
    let deltaText: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
            
            Text("vs período anterior")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(deltaText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isPositive ? .red : .green)
        }
    }
}

struct DataHonestyNote: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(text)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
