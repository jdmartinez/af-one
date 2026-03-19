import SwiftUI
import Charts

struct RhythmMapDetailView: View {
    @State private var viewModel = RhythmMapDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. Scenario Buttons (RHYM-01)
                scenarioButtonsSection

                // 2. Period Picker (RHYM-02)
                periodPickerSection

                // 3. Dual-Layer Chart (RHYM-03, RHYM-04)
                dualLayerChartSection

                // 4. Stats Row (RHYM-05)
                statsRowSection

                // 5. Data Coverage Bar (RHYM-07)
                coverageBarSection

                // 6. Circadian Pattern Histogram (RHYM-08)
                circadianHistogramSection

                // 7. Episode List (RHYM-06)
                episodeListSection

                // 8. Data Honesty Note
                dataHonestyNoteSection
            }
            .padding()
        }
        .navigationTitle("Mapa de Ritmo")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Scenario Buttons Section (RHYM-01)

    private var scenarioButtonsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Período")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(RhythmScenario.allCases) { scenario in
                    Button {
                        viewModel.selectedScenario = scenario
                        Task { await viewModel.loadData() }
                    } label: {
                        Text(scenario.rawValue)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedScenario == scenario ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedScenario == scenario
                                    ? Color.accentColor.opacity(0.15)
                                    : Color.secondary.opacity(0.08)
                            )
                            .foregroundStyle(
                                viewModel.selectedScenario == scenario
                                    ? Color.accentColor
                                    : Color.primary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Period Picker Section (RHYM-02)

    private var periodPickerSection: some View {
        Picker("Período", selection: $viewModel.selectedPeriod) {
            ForEach(RhythmPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            Task { await viewModel.loadData() }
        }
    }

    // MARK: - Dual-Layer Chart Section (RHYM-03, RHYM-04)

    private var dualLayerChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ritmo por hora")
                .font(.headline)

            Chart {
                // Bar layer: rhythm by hour
                ForEach(viewModel.hourlyData) { data in
                    BarMark(
                        x: .value("Hora", data.hour),
                        y: .value("Ritmo", barYValue(for: data.rhythmClassification))
                    )
                    .foregroundStyle(
                        barColor(for: data.rhythmClassification)
                            .opacity(data.sampleCount < 3 ? 0.35 : 1.0)
                    )
                    .cornerRadius(3)
                }

                // Line layer: HR trend overlay
                ForEach(viewModel.hrTrendData.filter { $0.averageHR != nil }) { point in
                    LineMark(
                        x: .value("Hora", point.hour),
                        y: .value("FC", hrLineY(for: point.averageHR ?? 0))
                    )
                    .foregroundStyle(Color.orange.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .chartXScale(domain: 0...23)
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 23]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text("\(hour):00")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 160)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let x = value.location.x
                                    if let hour: Int = proxy.value(atX: x) {
                                        viewModel.selectHour(hour)
                                    }
                                }
                        )
                }
            }
            .popover(isPresented: $viewModel.showHourDetail) {
                if let hour = viewModel.selectedHour,
                   let data = viewModel.hourlyData.first(where: { $0.hour == hour }) {
                    hourDetailPopover(data: data)
                }
            }

            // Legend
            chartLegend
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barYValue(for classification: RhythmClassification) -> Int {
        switch classification {
        case .sinusRhythm: return 1
        case .atrialFibrillation: return 2
        case .noData: return 0
        }
    }

    private func barColor(for classification: RhythmClassification) -> Color {
        switch classification {
        case .sinusRhythm: return Color(.systemBlue)
        case .atrialFibrillation: return Color.afOne.rhythmAF
        case .noData: return Color(.systemGray4)
        }
    }

    private func hrLineY(for hr: Int) -> Int {
        // Map HR to a visible range above bars (bars max at 2, HR line at 2.5-5)
        let normalized = Double(hr - 40) / 140.0  // 40-180 bpm range
        return 2 + Int(normalized * 3)  // 2-5 range, above bars
    }

    private var chartLegend: some View {
        HStack(spacing: 16) {
            legendItem(color: Color(.systemBlue), label: "Ritmo sinusal")
            legendItem(color: Color.afOne.rhythmAF, label: "FA")
            legendItem(color: Color.orange.opacity(0.7), label: "FC (línea)")
            legendItem(color: Color(.systemGray4), label: "Sin datos")
        }
        .font(.caption2)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 6)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }

    private func hourDetailPopover(data: HourlyRhythmData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(data.hourLabel)
                .font(.headline)

            Divider()

            HStack {
                Circle()
                    .fill(barColor(for: data.rhythmClassification))
                    .frame(width: 10, height: 10)
                Text(data.rhythmClassification.displayName)
                    .font(.subheadline)
            }

            Text("\(data.sampleCount) lecturas de FC")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let hr = data.averageHeartRate {
                Text("FC media: \(hr) lpm")
                    .font(.caption)
            }

            if data.sampleCount < 3 {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text("Datos insuficientes (est.)")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding()
        .presentationCompactAdaptation(.popover)
    }

    // MARK: - Stats Row Section (RHYM-05)

    private var statsRowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas")
                .font(.headline)

            HStack(spacing: 0) {
                statItem(
                    value: String(format: "%.0f%%", viewModel.stats.srPercentage) + " (est.)",
                    label: "RS",
                    color: Color(.systemBlue)
                )
                statDivider
                statItem(
                    value: String(format: "%.0f%%", viewModel.stats.afPercentage) + " (est.)",
                    label: "FA",
                    color: Color.afOne.rhythmAF
                )
                statDivider
                statItem(
                    value: String(format: "%.0f%%", viewModel.stats.noDataPercentage) + " (est.)",
                    label: "Sin datos",
                    color: Color(.systemGray4)
                )
                statDivider
                statItem(
                    value: "\(viewModel.stats.episodeCount)",
                    label: "Episodios",
                    color: Color.primary
                )
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 1, height: 30)
    }

    // MARK: - Data Coverage Bar Section (RHYM-07)

    private var coverageBarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Cobertura de datos")
                    .font(.headline)

                Spacer()

                Text(String(format: "%.0f%%", viewModel.stats.coveragePercentage))
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundStyle(coverageColor(for: viewModel.stats.coveragePercentage))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))

                    // Coverage fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [coverageColor(for: viewModel.stats.coveragePercentage).opacity(0.7),
                                        coverageColor(for: viewModel.stats.coveragePercentage)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (viewModel.stats.coveragePercentage / 100))
                }
            }
            .frame(height: 8)

            HStack {
                Text("0%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("100%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func coverageColor(for percentage: Double) -> Color {
        if percentage < 50 {
            return .red
        } else if percentage < 75 {
            return .orange
        } else {
            return .green
        }
    }

    // MARK: - Circadian Pattern Histogram (RHYM-08)

    private var circadianHistogramSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patrón circadiano")
                .font(.headline)

            Text("Frecuencia de inicio de FA por bloques de 3 horas")
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart {
                ForEach(viewModel.circadianBlocks) { block in
                    BarMark(
                        x: .value("Bloque", block.hourRangeText),
                        y: .value("Episodios", block.afOnsetCount)
                    )
                    .foregroundStyle(Color.afOne.rhythmAF.gradient)
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel(orientation: .verticalReversed)
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Episode List Section (RHYM-06)

    private var episodeListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodios")
                .font(.headline)

            if viewModel.episodeItems.isEmpty {
                emptyEpisodesView
            } else {
                ForEach(viewModel.episodeItems) { item in
                    EpisodeDetailRow(item: item)
                }
            }
        }
    }

    private var emptyEpisodesView: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No hay episodios en este período")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Data Honesty Note Section (DATA-01, DATA-05)

    private var dataHonestyNoteSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Las clasificaciones de ritmo con <3 muestras se muestran al 35% de opacidad (est.)")
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

// MARK: - Episode Detail Row

struct EpisodeDetailRow: View {
    let item: EpisodeDetailItem

    var body: some View {
        HStack(spacing: 12) {
            // Time
            VStack(alignment: .leading, spacing: 4) {
                Text(item.startDate, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(item.startDate, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Metrics
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.durationFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Text("FC: \(item.meanHR)–\(item.peakHR)")
                        .font(.caption)
                        .foregroundStyle(Color.afOne.rhythmAF)
                }
            }

            // Chips
            HStack(spacing: 6) {
                if let spo2 = item.minSpO2 {
                    Text("SpO2 \(spo2)%")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                } else {
                    Text("SpO2 —")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }

                if item.hasECG {
                    Text("ECG")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())
                }

                if item.insufficientData {
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
}

#Preview {
    NavigationStack {
        RhythmMapDetailView()
    }
}
