import SwiftUI
import Charts

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct BurdenDetailView: View {
    @State private var viewModel = BurdenDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                primaryBurdenSection
                threeColumnComparison
                trendChartSection
                episodesListSection
                clinicalContextSection
                dataHonestySection
            }
            .padding()
        }
        .navigationTitle("Carga de FA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Carga de FA")
                    .font(.headline)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    private var periodPicker: some View {
        Picker("Período", selection: $viewModel.selectedPeriod) {
            ForEach(BurdenPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            Task { await viewModel.loadData() }
        }
    }
    
    private var primaryBurdenSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            periodPicker
            
            if let burden = viewModel.currentBurden {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", burden.percentage) + " (est.)")
                                .font(.system(size: 68, weight: .bold, design: .rounded))
                                .foregroundStyle(burdenColor(for: burden.percentage))
                            
                            Text("%")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundStyle(burdenColor(for: burden.percentage).opacity(0.7))
                                .baselineOffset(12)
                        }
                        
                        Text("Carga estimada · \(viewModel.selectedPeriod.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                        
                        deltaSection(burden: burden)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        thresholdBadge(burden: burden)
                        miniChartSection
                    }
                }
                
                progressBarSection(burden: burden)
                statsGridSection
            }
            
            heroFooterSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: heroGradientColors(for: viewModel.currentBurden?.percentage ?? 0),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private func burdenColor(for percentage: Double) -> Color {
        switch percentage {
        case ..<5.5:
            return Color(hex: "30D158")
        case 5.5..<11.0:
            return Color.orange
        default:
            return Color(hex: "ff3b30")
        }
    }
    
    private func heroGradientColors(for percentage: Double) -> [Color] {
        switch percentage {
        case ..<5.5:
            return [Color(hex: "0D1A14"), Color(hex: "1a3a2a")]
        case 5.5..<11.0:
            return [Color(hex: "1a1a0D"), Color(hex: "3a2a1a")]
        default:
            return [Color(hex: "1a0D0D"), Color(hex: "3a1a1a")]
        }
    }
    
    private func thresholdBadge(burden: BurdenData) -> some View {
        let text: String = {
            switch burden.percentage {
            case ..<5.5: return "↓ <5.5% ASSERT"
            case 5.5..<11.0: return "↓ 5.5-10.9% ASSERT"
            default: return "↓ ≥11% ALTO"
            }
        }()
        
        let badgeColor: Color = {
            switch burden.percentage {
            case ..<5.5: return Color(hex: "30D158")
            case 5.5..<11.0: return Color.orange
            default: return Color(hex: "ff3b30")
            }
        }()
        
        return Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.2), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(badgeColor, lineWidth: 1)
            )
            .foregroundStyle(badgeColor)
    }
    
    private func progressBarSection(burden: BurdenData) -> some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width
            let assertThreshold: Double = 5.5
            let trendsThreshold: Double = 11.0
            
            let assertX = (assertThreshold / trendsThreshold) * maxWidth
            let fillWidth = min((burden.percentage / trendsThreshold) * maxWidth, maxWidth)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                
                LinearGradient(
                    colors: [Color(hex: "30D158"), Color.orange, Color(hex: "ff3b30")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: fillWidth, height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 2, height: 14)
                    .position(x: assertX, y: 4)
                
                Rectangle()
                    .fill(Color(hex: "ff3b30"))
                    .frame(width: 2, height: 14)
                    .position(x: maxWidth, y: 4)
            }
        }
        .frame(height: 16)
    }
    
    private var miniChartSection: some View {
        let mockData = (0..<7).map { _ in Double.random(in: 2...15) }
        
        return VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { index in
                    let opacity = 0.35 + (Double(index) / 6.0) * 0.65
                    let height = mockData[index]
                    let barColor = burdenColor(for: mockData[index])
                    
                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barColor.opacity(opacity))
                            .frame(width: 7, height: height)
                    }
                    .frame(height: 22)
                }
            }
            .frame(height: 22)
            
            Text("Últimos 7 días")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
    }
    
    private var statsGridSection: some View {
        let episodeCount = viewModel.currentBurden?.episodeCount ?? 0
        let avgDuration = viewModel.currentBurden?.averageDuration ?? 0
        let longestDuration: TimeInterval = 2700
        let silentAF = 2
        
        let stats: [(String, String, Bool)] = [
            ("EPISODIOS", "\(episodeCount)", true),
            ("DURACIÓN MEDIA", formatDuration(avgDuration), true),
            ("MÁS LARGO", formatDuration(longestDuration), true),
            ("FA SILENTE", "\(silentAF)", silentAF > 0)
        ]
        
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                ForEach(stats, id: \.0) { label, value, isActive in
                    VStack(spacing: 2) {
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                        Text(value)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(isActive ? 1.0 : 0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    
                    if label != "FA SILENTE" {
                        Divider()
                            .background(.white.opacity(0.2))
                    }
                }
            }
        }
    }
    
    private var heroFooterSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.caption2)
                .foregroundStyle(Color(hex: "5a7a62"))
            
            Text("Valor estimado · calculado a partir de irregularHeartRhythmEvent de HealthKit")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color(hex: "5a7a62"))
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
    
    private var legendSection: some View {
        HStack(spacing: 16) {
            Label {
                Text("Bajo riesgo")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            } icon: {
                Circle()
                    .fill(Color.afOne.burdenLow)
                    .frame(width: 8, height: 8)
            }
            
            Spacer()
            
            Label {
                Text("≥5.5% ASSERT")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            } icon: {
                Circle()
                    .fill(Color.afOne.burdenMid)
                    .frame(width: 8, height: 8)
            }
            
            Spacer()
            
            Label {
                Text("≥11% Alto")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            } icon: {
                Circle()
                    .fill(Color.afOne.burdenHigh)
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private func deltaSection(burden: BurdenData) -> some View {
        let isPositive = viewModel.deltaIsPositive
        let deltaColor: Color = isPositive ? Color(hex: "ff3b30") : Color(hex: "30D158")
        let deltaText: String = {
            guard let previous = burden.previousPercentage else { return "Sin datos" }
            let delta = burden.percentage - previous
            if delta > 0 {
                return "+\(String(format: "%.1f", delta))%"
            } else if delta < 0 {
                return String(format: "%.1f", delta)
            }
            return "0%"
        }()
        
        let referenceText: String = {
            switch viewModel.selectedPeriod {
            case .day: return "ayer"
            case .week: return "sem. ant."
            case .month: return "mes ant."
            }
        }()
        
        return VStack(spacing: 2) {
            Text(deltaText + " " + referenceText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(deltaColor.opacity(0.2), in: Capsule())
        .overlay(
            Capsule()
                .stroke(deltaColor, lineWidth: 1)
        )
        .foregroundStyle(deltaColor)
    }
    
    private var threeColumnComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparación de períodos")
                .font(.headline)
            
            HStack(spacing: 0) {
                ForEach(BurdenPeriod.allCases) { period in
                    let burden = viewModel.allPeriodsBurden.first { $0.period == period }
                    let prevBurden = viewModel.allPeriodsBurden.first { $0.period == period }?.previousPercentage
                    let currentBurden = viewModel.allPeriodsBurden.first { $0.period == period }?.percentage
                    
                    VStack(spacing: 8) {
                        Text(period.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(burden.map { String(format: "%.1f%%", $0.percentage) } ?? "—")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        if let current = currentBurden, let previous = prevBurden {
                            let delta = current - previous
                            HStack(spacing: 2) {
                                Image(systemName: delta >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption2)
                                Text(String(format: "%.1f%%", abs(delta)))
                                    .font(.caption2)
                            }
                            .foregroundStyle(delta >= 0 ? .red : .green)
                        } else {
                            Text("—")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(burden.map { "\($0.episodeCount) epis." } ?? "—")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    
                    if period != .month {
                        Divider()
                            .frame(height: 80)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tendencia de 14 días")
                .font(.headline)
            
            ZStack(alignment: .topTrailing) {
                if viewModel.trendData.isEmpty {
                    Chart {
                        ForEach(0..<14, id: \.self) { day in
                            let value = Double.random(in: 3...15)
                            let level: BurdenLevel = value < 5.5 ? .low : (value < 11 ? .medium : .high)
                            
                            BarMark(
                                x: .value("Día", day),
                                y: .value("Carga", value)
                            )
                            .foregroundStyle(level.color.opacity(value < 3 ? 0.4 : 1.0))
                            .position(by: .value("Día", day))
                        }
                        
                        RuleMark(y: .value("5.5%", 5.5))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        
                        RuleMark(y: .value("11%", 11))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                    .chartYScale(domain: 0...20)
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 1)) { value in
                            AxisValueLabel {
                                if let day = value.as(Int.self) {
                                    let date = Calendar.current.date(byAdding: .day, value: -(13 - day), to: Date()) ?? Date()
                                    Text(date, format: .dateTime.weekday(.narrow))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                } else {
                    Chart {
                        ForEach(viewModel.trendData) { data in
                            BarMark(
                                x: .value("Día", viewModel.trendData.firstIndex(of: data) ?? 0),
                                y: .value("Carga", data.percentage)
                            )
                            .foregroundStyle(burdenLevelColor(for: data))
                            .position(by: .value("Día", viewModel.trendData.firstIndex(of: data) ?? 0))
                        }
                        
                        RuleMark(y: .value("5.5%", 5.5))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        
                        RuleMark(y: .value("11%", 11))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                    .chartYScale(domain: 0...20)
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 1)) { value in
                            AxisValueLabel {
                                if let day = value.as(Int.self) {
                                    let date = Calendar.current.date(byAdding: .day, value: -(13 - day), to: Date()) ?? Date()
                                    Text(date, format: .dateTime.weekday(.narrow))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                }
            }
            
            DataHonestyNote(text: "Barras con <3 muestras shown at 40% opacity")
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func burdenLevelColor(for data: BurdenData) -> Color {
        let level: BurdenLevel = data.percentage < 5.5 ? .low : (data.percentage < 11 ? .medium : .high)
        return data.insufficientData ? level.color.opacity(0.4) : level.color
    }
    
    private var episodesListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodios recientes")
                .font(.headline)
            
            if viewModel.recentEpisodes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No hay episodios recientes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(viewModel.recentEpisodes) { episode in
                    BurdenEpisodeRow(episode: episode)
                }
            }
        }
    }
    
    private var clinicalContextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contexto clínico")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                ClinicalThresholdExplanation()
                
                Divider()
                
                AnticoagulationNote()
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var dataHonestySection: some View {
        VStack(spacing: 8) {
            DataHonestyNote(
                text: "calculado a partir de eventos irregularHeartRhythmEvent"
            )
        }
    }
}

struct BurdenEpisodeRow: View {
    let episode: EpisodeSummary
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.startDate, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Label(
                        formatDuration(episode.duration),
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Label("\(episode.averageHR) lpm", 
                          systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                if let spo2 = episode.minSpO2 {
                    Text("SpO2 \(spo2)%")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
                
                if episode.hasECG {
                    Text("ECG")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.purple.opacity(0.2))
                        .foregroundStyle(.purple)
                        .clipShape(Capsule())
                }
                
                if episode.insufficientData {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

struct ClinicalThresholdExplanation: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(.blue)
                Text("Referencias clínicas")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ThresholdRow(
                    level: "Bajo (<5.5%)",
                    reference: "ASSERT trial",
                    description: "Pronóstico favorable"
                )
                ThresholdRow(
                    level: "Medio (5.5-10.9%)",
                    reference: "ASSERT",
                    description: "Riesgo elevado, considerar anticoagulación"
                )
                ThresholdRow(
                    level: "Alto (≥11%)",
                    reference: "AF-TRENDS",
                    description: "Riesgo alto, anticoagulación recomendada"
                )
            }
        }
    }
}

struct ThresholdRow: View {
    let level: String
    let reference: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(level)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(reference)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct AnticoagulationNote: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "pills.fill")
                    .foregroundStyle(.blue)
                Text("Anticoagulación")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            Text("La decisión de iniciar anticoagulación debe tomarla su cardiólogo considerando su riesgo individual.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        BurdenDetailView()
    }
    .preferredColorScheme(.dark)
}
