import SwiftUI
import SwiftData
import Charts

struct SymptomCorrelationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomLog.timestamp, order: .reverse) private var allSymptoms: [SymptomLog]
    @State private var viewModel = SymptomCorrelationViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryGrid

                periodPicker

                if !viewModel.filteredItems.isEmpty {
                    correlationTimeline

                    eventList
                } else {
                    emptyStateView
                }

                patternsSection

                methodologicalNote
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("Correlación de Síntomas")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showDetailSheet) {
            if let item = viewModel.selectedItem {
                DetailSheetView(item: item)
            }
        }
        .task {
            await loadData()
        }
    }

    private var summaryGrid: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            SummaryColumn(
                count: viewModel.symptomsWithAfCount,
                label: "Con FA",
                color: .green,
                isActive: viewModel.selectedFilter == .withAF
            )
            .onTapGesture {
                viewModel.setFilter(viewModel.selectedFilter == .withAF ? .all : .withAF)
            }

            SummaryColumn(
                count: viewModel.symptomsWithoutAfCount,
                label: "Sin FA",
                color: .orange,
                isActive: viewModel.selectedFilter == .withoutAF
            )
            .onTapGesture {
                viewModel.setFilter(viewModel.selectedFilter == .withoutAF ? .all : .withoutAF)
            }

            SummaryColumn(
                count: viewModel.silentAfCount,
                label: "FA silente",
                color: .red,
                isActive: viewModel.selectedFilter == .silentAF
            )
            .onTapGesture {
                viewModel.setFilter(viewModel.selectedFilter == .silentAF ? .all : .silentAF)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var periodPicker: some View {
        Picker("Período", selection: $viewModel.selectedPeriod) {
            ForEach(CorrelationPeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            Task {
                await loadData()
            }
        }
    }

    private var correlationTimeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LÍNEA DE TIEMPO")
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            TimelineChartView(
                items: viewModel.filteredItems,
                period: viewModel.selectedPeriod
            )
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var eventList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("EVENTOS")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.selectedFilter != .all {
                    Button("Limpiar filtro") {
                        viewModel.setFilter(.all)
                    }
                    .font(.caption)
                }
            }

            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredItems) { item in
                    CorrelationItemRow(item: item)
                        .onTapGesture {
                            viewModel.selectItem(item)
                        }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Sin datos de correlación")
                .font(.headline)
            Text("Registra síntomas y episodios de FA para ver patrones de correlación.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PATRONES DETECTADOS")
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            if viewModel.detectedPatterns.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text("No se han detectado patrones preocupantes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                ForEach(viewModel.detectedPatterns) { pattern in
                    PatternCardView(pattern: pattern)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var methodologicalNote: some View {
        DataHonestyNote(
            text: "La correlación se basa en una ventana de ±30 minutos. Apple Watch no realiza un ECG continuo — los episodios detectados pueden no ser exhaustivos."
        )
    }

    private func loadData() async {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -viewModel.selectedPeriod.days, to: endDate) ?? endDate

        let filteredSymptoms = allSymptoms.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }

        let episodes: [RhythmEpisode]
        do {
            episodes = try await HealthKitService.shared.fetchEpisodes(from: startDate, to: endDate)
        } catch {
            episodes = []
        }

        await viewModel.loadData(symptoms: filteredSymptoms, episodes: episodes)
    }
}

// MARK: - Summary Column

private struct SummaryColumn: View {
    let count: Int
    let label: String
    let color: Color
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? color.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isActive ? color.opacity(0.4) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Timeline Chart

private struct TimelineChartView: View {
    let items: [CorrelationItem]
    let period: CorrelationPeriod

    private var indexCount: Int {
        switch period {
        case .day: return 24
        case .week: return 7
        case .month: return 30
        }
    }

    private var rhythmData: [CorrelationTimelineData] {
        let calendar = Calendar.current
        let now = Date()
        var data: [CorrelationTimelineData] = []

        switch period {
        case .day:
            for h in 0..<24 {
                let hourStart = calendar.date(bySettingHour: h, minute: 0, second: 0, of: now) ?? now
                let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart) ?? hourStart
                let hasAF = items.contains { item in
                    guard let ep = item.episode ?? item.overlappingEpisode else { return false }
                    return ep.startDate <= hourEnd && ep.endDate >= hourStart
                }
                let hasSymptom = items.contains { item in
                    guard let symptom = item.symptom else { return false }
                    return calendar.component(.hour, from: symptom.timestamp) == h
                }
                data.append(CorrelationTimelineData(
                    index: h,
                    label: String(format: "%02d:00", h),
                    isAF: hasAF,
                    hasSymptom: hasSymptom
                ))
            }
        case .week:
            for d in 0..<7 {
                guard let dayDate = calendar.date(byAdding: .day, value: -d, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: dayDate)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
                let hasAF = items.contains { item in
                    guard let ep = item.episode ?? item.overlappingEpisode else { return false }
                    return ep.startDate <= dayEnd && ep.endDate >= dayStart
                }
                let hasSymptom = items.contains { item in
                    guard let symptom = item.symptom else { return false }
                    return symptom.timestamp >= dayStart && symptom.timestamp < dayEnd
                }
                data.append(CorrelationTimelineData(
                    index: d,
                    label: dayDate.formatted(.dateTime.weekday(.narrow)),
                    isAF: hasAF,
                    hasSymptom: hasSymptom
                ))
            }
        case .month:
            for d in 0..<30 {
                guard let dayDate = calendar.date(byAdding: .day, value: -d, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: dayDate)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
                let hasAF = items.contains { item in
                    guard let ep = item.episode ?? item.overlappingEpisode else { return false }
                    return ep.startDate <= dayEnd && ep.endDate >= dayStart
                }
                let hasSymptom = items.contains { item in
                    guard let symptom = item.symptom else { return false }
                    return symptom.timestamp >= dayStart && symptom.timestamp < dayEnd
                }
                data.append(CorrelationTimelineData(
                    index: d,
                    label: String(format: "%02d", calendar.component(.day, from: dayDate)),
                    isAF: hasAF,
                    hasSymptom: hasSymptom
                ))
            }
        }
        return data
    }

    var body: some View {
        VStack(spacing: 4) {
            symptomTrack
            Divider()
            rhythmTrack
        }
    }

    private var symptomTrack: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(rhythmData.enumerated()), id: \.element.id) { slotIndex, slot in
                    symptomPinView(for: slotIndex, slot: slot)

                    if slotIndex < rhythmData.count - 1 {
                        Spacer()
                    }
                }
            }
            .frame(height: 44)
        }
    }

    @ViewBuilder
    private func symptomPinView(for slotIndex: Int, slot: CorrelationTimelineData) -> some View {
        let symptomInSlot: CorrelationItem? = {
            for item in items {
                guard let symptom = item.symptom else { continue }
                let cal = Calendar.current
                switch period {
                case .day:
                    if cal.component(.hour, from: symptom.timestamp) == slot.index {
                        return item
                    }
                default:
                    let dayStart = cal.date(byAdding: .day, value: slotIndex, to: cal.startOfDay(for: Date())) ?? Date()
                    let dayEnd = cal.date(byAdding: .day, value: slotIndex + 1, to: dayStart) ?? dayStart
                    if symptom.timestamp >= dayStart && symptom.timestamp < dayEnd {
                        return item
                    }
                }
            }
            return nil
        }()

        if let symptom = symptomInSlot {
            VStack(spacing: 2) {
                Circle()
                    .fill(symptom.correlationType == .faConfirmed ? Color.red : Color.orange)
                    .frame(width: 16, height: 16)
                    .overlay {
                        Text(String((symptom.symptom?.symptomType ?? "?").prefix(1)))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                Text("S")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
        } else {
            Circle()
                .fill(Color.clear)
                .frame(width: 16, height: 16)
        }
    }

    private var rhythmTrack: some View {
        Chart {
            ForEach(rhythmData) { slot in
                BarMark(
                    x: .value("Slot", slot.index),
                    y: .value("Rhythm", slot.isAF ? 1 : 0)
                )
                .foregroundStyle(slot.isAF ? Color.red.opacity(0.7) : Color.green.opacity(0.4))
                .cornerRadius(3)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: period == .day ? 4 : 1)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let idx = value.as(Int.self), idx < rhythmData.count {
                        Text(rhythmData[idx].label)
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...1)
        .frame(height: 60)
    }
}

private struct CorrelationTimelineData: Identifiable {
    let id = UUID()
    let index: Int
    let label: String
    let isAF: Bool
    let hasSymptom: Bool
}

// MARK: - Correlation Item Row

private struct CorrelationItemRow: View {
    let item: CorrelationItem

    private var symptomTypeText: String {
        if let symptom = item.symptom {
            return symptom.symptomType ?? "?"
        } else {
            return "FA silente"
        }
    }

    private var timestampText: String {
        let date = item.symptom?.timestamp ?? item.episode?.startDate ?? Date()
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private var descriptionText: String {
        switch item.correlationType {
        case .faConfirmed:
            return "Síntoma dentro de la ventana de ±30 min de un episodio de FA"
        case .noCorrelation:
            return "Síntoma sin FA coincidente — puede tener otras causas"
        case .silentAF:
            let duration = item.episode?.durationFormatted ?? "?"
            return "Episodio de FA de \(duration) sin síntoma reportado"
        }
    }

    private var badgeColor: Color {
        switch item.correlationType {
        case .faConfirmed: return .green
        case .noCorrelation: return .orange
        case .silentAF: return .red
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(badgeColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(symptomTypeText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(descriptionText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(timestampText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(item.correlationType.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(badgeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(badgeColor.opacity(0.15))
                .clipShape(Capsule())

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
        )
    }
}

// MARK: - Pattern Card

private struct PatternCardView: View {
    let pattern: PatternInfo

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                Text(pattern.clinicalNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        } label: {
            HStack {
                Text(pattern.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(pattern.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
        )
    }
}

// MARK: - Detail Sheet

private struct DetailSheetView: View {
    let item: CorrelationItem
    @Environment(\.dismiss) private var dismiss

    private var symptomTypeText: String {
        if let symptom = item.symptom {
            return symptom.symptomType ?? "?"
        } else {
            return "FA silente — sin síntoma reportado"
        }
    }

    private var timestampText: String {
        let date = item.symptom?.timestamp ?? item.episode?.startDate ?? Date()
        return date.formatted(date: .complete, time: .shortened)
    }

    private var notesText: String? {
        if let symptom = item.symptom {
            return symptom.notes
        }
        return "Episodio de fibrilación auricular detectado por Apple Watch sin síntoma reportado en la ventana de ±30 minutos."
    }

    private var clinicalNote: String {
        switch item.correlationType {
        case .faConfirmed:
            return "Síntoma dentro de la ventana de ±30 minutos de un episodio de FA confirmado. La correlación no implica causalidad — ambos eventos pueden ocurrir de forma independiente."
        case .noCorrelation:
            return "Síntoma sin episodio de FA coincidente en la ventana de ±30 minutos. La mayoría de los síntomas no están relacionados con FA — si los síntomas persisten, consulte a su médico."
        case .silentAF:
            return "FA silente: episodio de FA detectado sin síntomas reportados. La FA silente aumenta el riesgo de ictus. Informe a su cardiólogo sobre este hallazgo."
        }
    }

    private var badgeColor: Color {
        switch item.correlationType {
        case .faConfirmed: return .green
        case .noCorrelation: return .orange
        case .silentAF: return .red
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    symptomHeader

                    windowIndicator

                    notesSection

                    clinicalInterpretation
                }
                .padding(20)
            }
            .navigationTitle("Detalle del Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var symptomHeader: some View {
        HStack(spacing: 16) {
            VStack {
                Image(systemName: item.correlationType == .silentAF ? "heart.fill" : "waveform.path.ecg")
                    .font(.system(size: 32))
                    .foregroundStyle(badgeColor)
            }
            .frame(width: 60, height: 60)
            .background(badgeColor.opacity(0.15))
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(symptomTypeText)
                    .font(.headline)
                Text(timestampText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.correlationType.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(badgeColor)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var windowIndicator: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VENTANA DE CORRELACIÓN (±30 MIN)")
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)

                Rectangle()
                    .fill(badgeColor)
                    .frame(height: 8)

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
            }
            .clipShape(Capsule())

            HStack {
                Text(item.windowStart.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.symptom?.timestamp.formatted(date: .omitted, time: .shortened) ?? item.episode?.startDate.formatted(date: .omitted, time: .shortened) ?? "")
                    .font(.caption2.bold())
                    .foregroundStyle(badgeColor)
                Spacer()
                Text(item.windowEnd.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTAS")
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Text(notesText ?? "Sin notas")
                .font(.subheadline)
                .foregroundStyle(notesText != nil ? .primary : .secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var clinicalInterpretation: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "stethoscope")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("INTERPRETACIÓN CLÍNICA")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }

            Text(clinicalNote)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SymptomCorrelationView()
            .modelContainer(for: [SymptomLog.self])
    }
}
