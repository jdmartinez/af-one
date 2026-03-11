import SwiftUI

struct EpisodeListView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.red)

                Text("Episodes")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("AF episode history will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .navigationTitle("Episodes")
        }
    }
}

#Preview {
    EpisodeListView()
}
