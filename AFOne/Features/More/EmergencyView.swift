import SwiftUI
import Charts

struct EmergencyView: View {
    @State private var viewModel = EmergencyReportViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // EMER-01: Red Full-Bleed Header
                headerSection

                // EMER-02: Patient Block
                patientBlockSection

                // EMER-03: Episode Strip
                episodeStripSection

                // EMER-04: Current Episode Details
                if viewModel.currentEpisode != nil {
                    currentEpisodeSection
                }

                // EMER-05: AF History Section
                afHistorySection

                // EMER-06: Medications Section
                medicationsSection

                // EMER-07: Relevant History Timeline
                relevantHistorySection

                // EMER-08: Limitations Banner
                limitationsBanner

                // EMER-10: Emergency Call Button
                emergencyCallButton

                // EMER-09: Source Footer
                sourceFooterSection

                // Bottom safe area padding
                Color.clear.frame(height: 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Informe de Emergencia")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadAllData()
        }
    }

    // MARK: - EMER-01: Red Full-Bleed Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            // Urgency Badge
            Text(viewModel.urgencyBadgeText)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.9))
                .clipShape(Capsule())

            // App Name
            Text("AFOne")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            // Timestamp
            Text(viewModel.generatedAt.formatted(date: .numeric, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [Color.red, Color.red.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - EMER-02: Patient Block

    private var patientBlockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Datos del Paciente", systemImage: "person.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            Divider()

            if let patient = viewModel.patientInfo {
                // Name
                HStack {
                    Text(patient.name)
                        .font(.title3.bold())
                    Spacer()
                }

                // Age and Sex
                HStack(spacing: 16) {
                    if let age = patient.age {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("\(age) años")
                                .font(.subheadline)
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "figure.dress.line.vertical.figure")
                            .font(.caption)
                        Text(patient.sex)
                            .font(.subheadline)
                    }

                    Spacer()
                }
                .foregroundStyle(.secondary)

                // Known Diagnoses
                VStack(alignment: .leading, spacing: 6) {
                    Text("Diagnósticos conocidos")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(patient.knownDiagnoses, id: \.self) { diagnosis in
                            Text(diagnosis)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(diagnosis.lowercased().contains("fibrilación") ? Color.red : Color.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            } else if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - EMER-03: Episode Strip

    private var episodeStripSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Episodio Actual", systemImage: "waveform.path.ecg")
                .font(.headline)

            Divider()

            if let episode = viewModel.currentEpisode {
                HStack(spacing: 0) {
                    // Elapsed Time
                    VStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text(viewModel.elapsedTimeFormatted)
                            .font(.title3.bold().monospacedDigit())
                        Text("Desde inicio")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .frame(height: 50)

                    // Current HR
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundStyle(episode.currentHR ?? 0 > 100 ? .red : .pink)
                        Text("\(episode.currentHR ?? 0)")
                            .font(.title3.bold().monospacedDigit()) +
                        Text(" lpm")
                            .font(.caption)
                        Text("FC actual")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .frame(height: 50)

                    // SpO2
                    VStack(spacing: 4) {
                        Image(systemName: "lungs.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("\(episode.currentSpO2 ?? 0)")
                            .font(.title3.bold().monospacedDigit()) +
                        Text("%")
                            .font(.caption)
                        Text("SpO₂")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Text("Sin episodio activo")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - EMER-04: Current Episode Details

    private var currentEpisodeSection: some View {
        let episode = viewModel.currentEpisode

        return VStack(alignment: .leading, spacing: 12) {
            Label("Detalles del Episodio", systemImage: "list.bullet.clipboard")
                .font(.headline)

            Divider()

            VStack(spacing: 10) {
                // Onset Time
                DetailRow(
                    icon: "clock.badge.checkmark",
                    label: "Inicio",
                    value: episode?.onsetTime.formatted(date: .abbreviated, time: .shortened) ?? "--"
                )

                // Duration
                DetailRow(
                    icon: "hourglass",
                    label: "Duración",
                    value: episode?.elapsedTimeFormatted ?? "--"
                )

                // Mean HR
                DetailRow(
                    icon: "heart.fill",
                    label: "FC media",
                    value: episode?.meanHR != nil ? "\(episode!.meanHR!) lpm" : "--"
                )

                // Peak HR
                DetailRow(
                    icon: "heart.fill",
                    label: "FC máxima",
                    value: episode?.peakHR != nil ? "\(episode!.peakHR!) lpm" : "--"
                )

                // SpO2
                DetailRow(
                    icon: "lungs.fill",
                    label: "SpO₂ mínima",
                    value: episode?.currentSpO2 != nil ? "\(episode!.currentSpO2!)%" : "--"
                )

                // ECG
                DetailRow(
                    icon: "waveform.path.ecg",
                    label: "ECG disponible",
                    value: episode?.hasECG == true ? "Sí" : "No"
                )
            }

            // Symptoms
            if let symptoms = episode?.symptoms, !symptoms.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Síntomas reportados")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(symptoms, id: \.self) { symptom in
                            Text(symptom)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - EMER-05: AF History Section

    private var afHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Historia de FA (30 días)", systemImage: "chart.bar.fill")
                .font(.headline)

            Divider()

            if let history = viewModel.afHistory {
                // 30-day mini timeline chart
                MiniBurdenChart(data: history.thirtyDayBurdenTimeline)
                    .frame(height: 80)

                // Stats Grid
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]

                LazyVGrid(columns: columns, spacing: 12) {
                    StatBox(value: "\(history.episodeCount)", label: "Episodios", color: .blue)
                    StatBox(value: history.meanDurationFormatted, label: "Duración media", color: .orange)
                    StatBox(value: String(format: "%.1f%%", history.burdenPercentage), label: "Carga FA", color: burdenColor(history.burdenPercentage))
                    StatBox(value: history.afType.rawValue, label: "Tipo FA", color: .purple)
                }
            } else if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                Text("Sin datos disponibles")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - EMER-06: Medications Section

    private var medicationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Medicación Actual", systemImage: "pills.fill")
                .font(.headline)

            Divider()

            if viewModel.medications.isEmpty && !viewModel.isLoading {
                Text("Sin datos de medicación")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(MedicationClass.allCases, id: \.self) { medClass in
                    if let meds = viewModel.medications[medClass], !meds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            // Class Header with Badge
                            HStack(spacing: 8) {
                                Text(medClass.rawValue)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)

                                ClassBadge(medClass: medClass)
                            }

                            // Medication Rows
                            ForEach(meds) { med in
                                HStack {
                                    Image(systemName: "pills.fill")
                                        .font(.caption)
                                        .foregroundStyle(medClass.badgeColor)

                                    Text(med.name)
                                        .font(.subheadline)

                                    if let dose = med.dose {
                                        Text("— \(dose)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        if medClass != MedicationClass.allCases.last {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - EMER-07: Relevant History Timeline

    private var relevantHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Historia Médica Relevante", systemImage: "list.bullet.rectangle")
                .font(.headline)

            Divider()

            if viewModel.medicalHistory.isEmpty && !viewModel.isLoading {
                Text("Sin datos disponibles")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.medicalHistory) { item in
                        HStack(alignment: .top, spacing: 12) {
                            // Timeline dot and line
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(item.categoryColor)
                                    .frame(width: 10, height: 10)

                                if item.id != viewModel.medicalHistory.last?.id {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.3))
                                        .frame(width: 2)
                                        .frame(minHeight: 30)
                                }
                            }

                            // Content
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Image(systemName: item.categoryIcon)
                                        .font(.caption)
                                        .foregroundStyle(item.categoryColor)

                                    Text(item.category)
                                        .font(.caption.bold())
                                        .foregroundStyle(item.categoryColor)
                                }

                                Text(item.description)
                                    .font(.subheadline)

                                if let date = item.date {
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.bottom, 12)

                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - EMER-08: Limitations Banner

    private var limitationsBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            Text(viewModel.limitationsText)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - EMER-10: Emergency Call Button

    private var emergencyCallButton: some View {
        Button(action: {
            if let url = URL(string: "tel://112") {
                openURL(url)
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "phone.fill")
                    .font(.headline)
                Text("Llamar 112")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - EMER-09: Source Footer

    private var sourceFooterSection: some View {
        VStack(spacing: 4) {
            Text("Generado por AFOne v1.0 — \(viewModel.generatedAt.formatted(date: .numeric, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("Este informe no sustituye el criterio médico profesional.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }

    // MARK: - Helpers

    private func burdenColor(_ percentage: Double) -> Color {
        if percentage < 5.5 { return .green }
        if percentage < 11 { return .orange }
        return .red
    }
}

// MARK: - Supporting Views

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.bold())
        }
    }
}

private struct StatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ClassBadge: View {
    let medClass: MedicationClass

    var body: some View {
        Text(medClass.rawValue)
            .font(.caption2.bold())
            .foregroundStyle(medClass.badgeColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(medClass.badgeColor.opacity(0.15))
            .clipShape(Capsule())
    }
}

private struct MiniBurdenChart: View {
    let data: [Double]

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                BarMark(
                    x: .value("Día", index),
                    y: .value("Carga", value)
                )
                .foregroundStyle(barColor(for: value))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 10, 20]) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: 0...20)
    }

    private func barColor(for value: Double) -> Color {
        if value < 5.5 { return .green }
        if value < 11 { return .orange }
        return .red
    }
}


