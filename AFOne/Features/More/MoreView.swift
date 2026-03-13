import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Health") {
                    NavigationLink(destination: EmergencyView()) {
                        Label("Emergency Information", systemImage: "exclamationmark.triangle")
                    }
                    
                    NavigationLink(destination: ReportView()) {
                        Label("Clinical Report", systemImage: "doc.text.fill")
                    }
                }

                Section("Settings") {
                    NavigationLink(destination: SettingsView()) {
                        Label("App Settings", systemImage: "gear")
                    }
                }

                Section("About") {
                    NavigationLink(destination: AboutView()) {
                        Label("About AFOne", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Section("Notifications") {
                Toggle("AF Alerts", isOn: .constant(true))
            }

            Section("Data") {
                NavigationLink("Disclaimer") {
                    DisclaimerView()
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.red)

                    Text("AFOne")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section {
                Text("AFOne reads heart rhythm data from Apple Watch to help you understand your atrial fibrillation patterns.")
                    .font(.body)
            }

            Section {
                NavigationLink(destination: DisclaimerView()) {
                    Text("Disclaimer")
                }
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    MoreView()
}
