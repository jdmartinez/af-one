import SwiftUI
import Charts

struct BurdenDetailView: View {
    @State private var viewModel = BurdenDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                periodPicker
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
        VStack(alignment: .leading, spacing: 12) {
            if let burden = viewModel.currentBurden {
                primaryValueSection(burden: burden)
                progressBarSection(burden: burden)
                legendSection
                deltaSection(burden: burden)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func primaryValueSection(burden: BurdenData) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.1f", burden.percentage))
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.burdenLevel.color)
            
            Text("%")
                .font(.title3)
                .foregroundStyle(.secondary)
                .baselineOffset(8)
            
            Spacer()
            
            thresholdBadge(burden: burden)
        }
    }
    
    private func thresholdBadge(burden: BurdenData) -> some View {
        let text: String = {
            switch burden.percentage {
            case ..<5.5: return "↓ ASSERT <5.5%"
            case 5.5..<11.0: return "5.5-10.9% ASSERT"
            default: return "≥11% Alto"
            }
        }()
        
        return Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(viewModel.burdenLevel.color.opacity(0.15), in: Capsule())
            .foregroundStyle(viewModel.burdenLevel.color.opacity(0.7))
    }
    
    private func progressBarSection(burden: BurdenData) -> some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width
            let fillWidth = min((burden.percentage / 11.0) * maxWidth, maxWidth)
            let midPoint = maxWidth / 2
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemFill))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.afOne.burdenLow, viewModel.burdenLevel.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth, height: 6)
                
                Rectangle()
                    .fill(Color.afOne.burdenMid.opacity(0.6))
                    .frame(width: 2, height: 12)
                    .position(x: midPoint, y: 6)
                
                Rectangle()
                    .fill(Color.afOne.burdenHigh.opacity(0.6))
                    .frame(width: 2, height: 12)
                    .position(x: maxWidth, y: 6)
            }
        }
        .frame(height: 12)
    }
    
    private var legendSection: some View {
        HStack(spacing: 16) {
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
    
    private func deltaSection(burden: BurdenData) -> some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.deltaIsPositive ? "arrow.up" : "arrow.down")
                    Text(viewModel.deltaText)
                }
                .font(.caption)
                .foregroundStyle(viewModel.deltaIsPositive ? Color.afOne.rhythmAF : Color.afOne.rhythmSinusal)
                
                Spacer()
                
                Text("\(burden.episodeCount) episodios")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
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
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                
                if episode.hasECG {
                    Text("ECG")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(.secondarySystemBackground))
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
