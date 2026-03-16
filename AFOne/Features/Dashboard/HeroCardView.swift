import SwiftUI

// MARK: - Hero Card View
/// Zone 1 - The dominant element showing current rhythm status
/// with SR and AF Active states per SPEC.md Section 4
struct HeroCardView: View {
    // MARK: - Properties
    let isAFActive: Bool
    let currentHR: Int?
    let lastEpisodeDuration: String?
    let episodesToday: Int
    let confidenceLevel: String
    let episodeStartDate: Date?
    
    // State B - Recent Episode parameters
    let hasRecentEpisode: Bool
    let recentEpisodeEndDate: Date?
    
    @State private var isPulsing = false
    @State private var currentTime = Date()
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Computed Properties
    private var isStateB: Bool {
        !isAFActive && hasRecentEpisode
    }
    
    private var rhythmColor: Color {
        if isStateB {
            return Color.orange
        }
        return isAFActive ? Color.afOne.rhythmAF : Color.afOne.rhythmSinusal
    }
    
    private var rhythmLabel: String {
        if isStateB {
            return "Ritmo Sinusal"
        }
        return isAFActive ? "Fibrilación Auricular" : "Ritmo Sinusal"
    }
    
    private var confidenceBadge: String {
        isAFActive ? "Confirmado" : confidenceLevel
    }
    
    private var glowRadius: CGFloat {
        if isStateB {
            return 6
        }
        return isAFActive ? 8 : 6
    }
    
    private var gradientColors: [Color] {
        if isAFActive {
            return [
                Color.afOne.rhythmAF.opacity(0.15),
                Color.afOne.rhythmAF.opacity(0.05),
                Color.clear
            ]
        } else {
            // State B uses same gradient as SR (only banner is amber)
            return [
                Color.afOne.rhythmSinusal.opacity(0.1),
                Color.afOne.rhythmSinusal.opacity(0.03),
                Color.clear
            ]
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Section label
            HStack {
                Text("CURRENT RHYTHM")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Rhythm indicator row
            rhythmRow
            
            Divider()
                .padding(.vertical, 12)
            
            // Episode banner (AF Active only)
            if isAFActive {
                episodeBanner
                    .padding(.bottom, 12)
            }
            
            // Recent episode banner (State B - amber)
            if isStateB {
                recentEpisodeBanner
                    .padding(.bottom, 12)
            }
            
            // Stats row
            statsRow
            
            // Timestamp footer
            timestampFooter
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))

                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(isStateB ? 0.3 : (isAFActive ? 0.35 : 0.25))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    rhythmColor.opacity(isStateB ? 0.4 : (isAFActive ? 0.5 : 0.15)),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityValue(accessibilityTimerValue)
        .onAppear {
            if !reduceMotion {
                isPulsing = true
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
    }
    
    // MARK: - Rhythm Row
    private var rhythmRow: some View {
        HStack(spacing: 12) {
            // Animated rhythm indicator
            rhythmIndicator
            
            // Rhythm label
            Text(rhythmLabel)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Confidence badge
            Text(confidenceBadge)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemFill))
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Rhythm Indicator
    private var rhythmIndicator: some View {
        ZStack {
            Circle()
                .fill(rhythmColor)
                .frame(width: 10, height: 10)
                .shadow(color: rhythmColor, radius: glowRadius)
            
            if !reduceMotion {
                Circle()
                    .fill(rhythmColor)
                    .frame(width: 10, height: 10)
                    .scaleEffect(isPulsing ? 0.85 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }
        }
        .onAppear {
            if !reduceMotion {
                isPulsing = true
            }
        }
    }
    
    // MARK: - Episode Banner
    private var episodeBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("EPISODIO ACTIVO")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.afOne.rhythmAF)
                
                if let startDate = episodeStartDate {
                    Text(timerText(from: startDate))
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Text("Desde últimos datos de Apple Watch")
                    .font(.caption2)
                    .foregroundStyle(Color.afOne.rhythmAF.opacity(0.6))
                
                if let startDate = episodeStartDate {
                    Text("Desde \(onsetTime(from: startDate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Emergency button
            NavigationLink(destination: EmergencyView()) {
                HStack(spacing: 4) {
                    Image(systemName: "phone.fill")
                    Text("Urgencias")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(minWidth: 44, minHeight: 44)
                .padding(.horizontal, 12)
                .background(Color.afOne.rhythmAF)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.afOne.rhythmAF.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Recent Episode Banner (State B)
    private var recentEpisodeBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("EPISODIO RECIENTE")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.orange)
                
                if let endDate = recentEpisodeEndDate {
                    Text(elapsedTimeText(from: endDate))
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
            
            NavigationLink(destination: EmergencyView()) {
                HStack(spacing: 4) {
                    Text("Ver informe")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(Color.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            // Current HR
            statColumn(
                label: "FC ACTUAL",
                value: isAFActive && currentHR != nil ? "\(currentHR!) LPM" : "--",
                subLabel: isAFActive ? "Irregular" : "En reposo"
            )
            
            Divider()
                .frame(height: 40)
            
            // Last Episode
            statColumn(
                label: "ÚLTIMO EP.",
                value: isAFActive ? "--" : (lastEpisodeDuration ?? "--"),
                subLabel: isAFActive ? "Episodio activo" : "hace 3h · 28 min"
            )
            
            Divider()
                .frame(height: 40)
            
            // Episodes Today
            statColumn(
                label: "EPISODIOS HOY",
                value: "\(episodesToday)",
                subLabel: "↑ 1 vs ayer"
            )
        }
    }
    
    // MARK: - Stat Column
    private func statColumn(label: String, value: String, subLabel: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.tertiary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text(subLabel)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Timestamp Footer
    private var timestampFooter: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(rhythmColor.opacity(0.6))
                .frame(width: 5, height: 5)
            
            Text("Actualizado hace 42 seg · Apple Watch")
                .font(.caption2)
                .foregroundStyle(.secondary.opacity(0.6))
            
            Spacer()
        }
        .padding(.top, 12)
    }
    
    // MARK: - Helpers
    private func timerText(from date: Date) -> String {
        let interval = currentTime.timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func onsetTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func elapsedTimeText(from date: Date) -> String {
        let interval = currentTime.timeIntervalSince(date)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "hace \(hours)h \(minutes)min"
        } else {
            return "hace \(minutes)min"
        }
    }
    
    private var accessibilityDescription: String {
        if isAFActive {
            return "Fibrilación auricular en progreso. Episodio confirmado."
        } else {
            return "Ritmo sinusal. Frecuencia cardiaca \(currentHR ?? 0) latidos por minuto."
        }
    }
    
    private var accessibilityTimerValue: String {
        guard isAFActive, let startDate = episodeStartDate else {
            return ""
        }
        
        let interval = currentTime.timeIntervalSince(startDate)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return "\(hours) horas, \(minutes) minutos, \(seconds) segundos"
        } else if minutes > 0 {
            return "\(minutes) minutos, \(seconds) segundos"
        } else {
            return "\(seconds) segundos"
        }
    }
}

// MARK: - Preview
#Preview("SR State") {
    HeroCardView(
        isAFActive: false,
        currentHR: 62,
        lastEpisodeDuration: "14 h",
        episodesToday: 2,
        confidenceLevel: "Alta confianza",
        episodeStartDate: nil,
        hasRecentEpisode: false,
        recentEpisodeEndDate: nil
    )
    .preferredColorScheme(.dark)
}

#Preview("AF Active") {
    HeroCardView(
        isAFActive: true,
        currentHR: 118,
        lastEpisodeDuration: nil,
        episodesToday: 1,
        confidenceLevel: "Alta",
        episodeStartDate: Date().addingTimeInterval(-1800),
        hasRecentEpisode: false,
        recentEpisodeEndDate: nil
    )
    .preferredColorScheme(.dark)
}

#Preview("State B - Recent Episode") {
    HeroCardView(
        isAFActive: false,
        currentHR: 65,
        lastEpisodeDuration: "2h 15min",
        episodesToday: 1,
        confidenceLevel: "Alta confianza",
        episodeStartDate: nil,
        hasRecentEpisode: true,
        recentEpisodeEndDate: Date().addingTimeInterval(-7200)
    )
    .preferredColorScheme(.dark)
}
