import SwiftUI

struct TimelineView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Timeline")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("View your rhythm patterns over time")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .navigationTitle("Timeline")
        }
    }
}

#Preview {
    TimelineView()
}
