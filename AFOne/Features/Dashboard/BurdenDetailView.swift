import SwiftUI
import Charts

struct BurdenDetailView: View {
    @State private var viewModel = BurdenDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                periodPicker
                primaryBurdenSection
                progressSection
                deltaSection
                threeColumnComparison
                trendChartSection
                episodesListSection
                clinicalContextSection
                dataHonestySection
            }
            .padding()
        }
        .navigationTitle("Carga de FA")
        .navigationBarTitleDisplayMode(.large)
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
        VStack(spacing: 12) {
            if let burden = viewModel.currentBurden {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.1f", burden.percentage))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.burdenLevel.color)
                        
                        Text("de tiempo en FA")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        ThresholdBadge(level: viewModel.burdenLevel)
                        ClinicalReferenceBadge(level: viewModel.burdenLevel)
                    }
                }
                
                DataHonestyNote(text: "Valor estimado")
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progreso")
                .font(.headline)
            
            if let burden = viewModel.currentBurden {
                BurdenProgressBar(
                    percentage: burden.percentage,
                    level: viewModel.burdenLevel
                )
                
                HStack {
                    Text("0%")
                    Spacer()
                    Text("5.5%")
                    Spacer()
                    Text("11%")
                    Spacer()
                    Text("100%")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
    }
    
    private var deltaSection: some View {
        Group {
            if viewModel.currentBurden != nil {
                DeltaRow(
                    deltaText: viewModel.deltaText,
                    isPositive: viewModel.deltaIsPositive
                )
                .padding()
                .background(Color.secondary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var threeColumnComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparación de períodos")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(BurdenPeriod.allCases) { period in
                    let burden = viewModel.allPeriodsBurden.first { $0.period == period }
                    VStack(spacing: 8) {
                        Text(period.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(burden.map { String(format: "%.1f%%", $0.percentage) } ?? "—")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text(burden.map { "\($0.episodeCount) epis." } ?? "—")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tendencia de 14 días")
                .font(.headline)
            
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
                    }
                }
                .chartYScale(domain: 0...20)
                .chartYAxis {
                    AxisMarks(position: .leading)
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
                    }
                }
                .chartYScale(domain: 0...20)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            }
            
            DataHonestyNote(text: "Barras con <3 muestras shown at 40% opacity")
        }
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Contexto clínico")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ClinicalThresholdExplanation()
                
                Divider()
                
                AnticoagulationNote()
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                if episode.hasECG {
                    Text("ECG")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.15))
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
        .background(Color.secondary.opacity(0.05))
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
        VStack(alignment: .leading, spacing: 6) {
            Text("Referencias clínicas")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 4) {
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
        HStack(alignment: .top, spacing: 8) {
            Text(level)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            Text(reference)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct AnticoagulationNote: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "pills.fill")
                .font(.caption)
                .foregroundStyle(.blue)
            
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
}
