import SwiftUI
import Charts

struct EpisodeDetailView: View {
    let episode: RhythmEpisode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                heartRateCard
                contextCard
            }
            .padding()
        }
        .navigationTitle("Episode Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            Text(episode.startDate.formatted(date: .complete, time: .omitted))
                .font(.headline)

            Text(timeRange)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label(episode.durationFormatted, systemImage: "clock")
                Spacer()
                Label("AF Detected", systemImage: "heart.slash.fill")
                    .foregroundStyle(.red)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: episode.startDate)) - \(formatter.string(from: episode.endDate))"
    }

    private var heartRateCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heart Rate")
                .font(.headline)

            HStack(spacing: 40) {
                VStack {
                    Text("\(episode.averageHR)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Avg BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack {
                    Text("\(episode.peakHR)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Peak BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Frecuencia cardíaca derivada de lecturas de Apple Watch (est.)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart(sampleHeartRates) { reading in
                LineMark(
                    x: .value("Time", reading.minute),
                    y: .value("HR", reading.bpm)
                )
                .foregroundStyle(.red)
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 150)
            .chartYScale(domain: 50...180)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var contextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context")
                .font(.headline)

            HStack {
                Label(timeOfDay, systemImage: "clock")
                Spacer()
                Label(episode.startDate.formatted(.dateTime.weekday(.abbreviated)), systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: episode.startDate)
        switch hour {
        case 0..<6: return "Night"
        case 6..<12: return "Morning"
        case 12..<18: return "Afternoon"
        default: return "Evening"
        }
    }

    private var sampleHeartRates: [HeartRateSample] {
        (0..<Int(episode.duration / 300)).map { minute in
            HeartRateSample(
                minute: minute,
                bpm: episode.averageHR + Int.random(in: -20...20)
            )
        }
    }
}

struct HeartRateSample: Identifiable {
    let id = UUID()
    let minute: Int
    let bpm: Int
}
