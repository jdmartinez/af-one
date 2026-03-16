import SwiftUI

struct AuthorizationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthorizationViewModel()
    var onAuthorized: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.afOne.rhythmAF)

            VStack(spacing: 16) {
                Text("Welcome to AFOne")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("AFOne reads heart rhythm data from Apple Watch to help you understand your atrial fibrillation patterns.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 12) {
                Label("Heart Rate", systemImage: "heart.fill")
                Label("AF Burden", systemImage: "waveform.path.ecg")
                Label("Heart Rate Variability", systemImage: "waveform")
                Label("ECG Readings", systemImage: "ECG")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()

            if let error = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)

                    Button(action: openSettings) {
                        Text("Open Settings")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
            } else {
                Button(action: requestAuthorization) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(viewModel.isLoading ? "Requesting..." : "Continue")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
            }

            Text("Your health data stays on your device and is never shared.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom)
        }
        .onChange(of: viewModel.authorizationStatus) { _, newValue in
            if newValue == .authorized {
                onAuthorized?()
            }
        }
    }

    private func requestAuthorization() {
        Task {
            await viewModel.requestAuthorization()
        }
    }

    private func openSettings() {
    }
}
