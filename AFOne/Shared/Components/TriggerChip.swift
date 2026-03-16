import SwiftUI

struct TriggerChip: View {
    let trigger: TriggerType
    @Binding var isSelected: Bool
    var showIntensity: Bool = false
    @Binding var intensity: String?
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            Text(trigger.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color(.systemBlue).opacity(0.2) : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color(.systemBlue) : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color(.systemBlue) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        TriggerChip(trigger: .caffeine, isSelected: .constant(false), showIntensity: false, intensity: .constant(nil))
        TriggerChip(trigger: .caffeine, isSelected: .constant(true), showIntensity: true, intensity: .constant("high"))
    }
}
