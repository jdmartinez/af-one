import SwiftUI

/// Symptom Capture Button - Zone 5 of the Dashboard
/// Implements SPECIFICATION.md Section 8
struct SymptomCaptureButton: View {
    @Binding var showLogSheet: Bool
    let isAFActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // AF Active state: Show second button above primary
            if isAFActive {
                afActiveButton
            }
            
            // Primary button (SR State)
            primaryButton
        }
    }
    
    // MARK: - Primary Button (SR State)
    private var primaryButton: some View {
        Button(action: { showLogSheet = true }) {
            HStack(spacing: 14) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(.systemBlue))
                }
                
                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text("Capturar síntoma")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Registrar + iniciar ECG de 30s")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Trailing chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.afOne.rhythmSinusal.opacity(0.08))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Capturar síntoma")
        .accessibilityHint("Abre el formulario para registrar síntomas e iniciar ECG de 30 segundos")
    }
    
    // MARK: - AF Active Button
    private var afActiveButton: some View {
        Button(action: { showLogSheet = true }) {
            HStack(spacing: 14) {
                // Icon container with AF tint
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.afOne.rhythmAF.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.title3)
                        .foregroundStyle(Color.afOne.rhythmAF)
                }
                
                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text("Episodio en curso — Capturar contexto")
                        .font(.headline)
                        .foregroundStyle(Color.afOne.rhythmAF)
                    
                    Text("Registrar síntomas durante el episodio activo")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Trailing chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.afOne.rhythmAF.opacity(0.08))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.afOne.rhythmAF.opacity(0.3), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Episodio en curso — Capturar contexto")
        .accessibilityHint("Registrar síntomas durante el episodio activo de fibrilación auricular")
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("SR State")
            .font(.headline)
        
        SymptomCaptureButton(showLogSheet: .constant(false), isAFActive: false)
        
        Text("AF Active State")
            .font(.headline)
        
        SymptomCaptureButton(showLogSheet: .constant(false), isAFActive: true)
    }
    .padding()
    .preferredColorScheme(.dark)
}
