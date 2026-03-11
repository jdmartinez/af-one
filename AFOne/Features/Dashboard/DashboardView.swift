import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.red)

                Text("AFOne")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Dashboard")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: EmergencyView()) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
