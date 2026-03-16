import SwiftUI

struct DisclaimerView: View {
    @AppStorage("hasAcknowledgedDisclaimer") private var hasAcknowledged = false
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool> = .constant(false)) {
        self._isPresented = isPresented
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Not a Medical Device")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                Text("AFOne is for informational purposes only.")
                    .font(.body)

                Text("This app is not intended to:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Diagnose any medical condition", systemImage: "xmark.circle")
                    Label("Replace professional medical advice", systemImage: "xmark.circle")
                    Label("Monitor or treat heart conditions", systemImage: "xmark.circle")
                    Label("Replace FDA-cleared medical devices", systemImage: "xmark.circle")
                }
                .font(.subheadline)

                Text("Always consult with your cardiologist for medical decisions. If you experience symptoms, seek emergency medical attention immediately.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: acknowledge) {
                Text("I Understand")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func acknowledge() {
        hasAcknowledged = true
        isPresented = false
    }
}
