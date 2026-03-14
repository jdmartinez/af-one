import SwiftUI

struct EmergencyView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section("Diagnosis") {
                HStack {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundStyle(.red)
                    Text("Atrial Fibrillation")
                }
                Text("From Medical ID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Medications") {
                ForEach(["Apixaban 5mg", "Metoprolol 25mg"], id: \.self) { med in
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundStyle(.blue)
                        Text(med)
                    }
                }
                Text("From Medical ID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Emergency Contact") {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading) {
                        Text("Jane Doe (Spouse)")
                        Text("555-0123")
                            .foregroundStyle(.secondary)
                    }
                }
                Text("From Medical ID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button(action: {
                    if let url = URL(string: "x-apple-health://") {
                        openURL(url)
                    }
                }) {
                    Label("Open Health App", systemImage: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Emergency")
    }
}
