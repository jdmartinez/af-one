import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LogViewModel()
    @State private var showNotes: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Symptoms Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How are you feeling?", systemImage: "heart.text.square")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(SymptomType.allCases, id: \.self) { symptom in
                                SymptomChip(
                                    symptom: symptom,
                                    isSelected: .init(
                                        get: { viewModel.selectedSymptoms.contains(symptom) },
                                        set: { isSelected in
                                            if isSelected {
                                                viewModel.selectedSymptoms.insert(symptom)
                                            } else {
                                                viewModel.selectedSymptoms.remove(symptom)
                                            }
                                        }
                                    )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Triggers Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Any triggers?", systemImage: "bolt")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(TriggerType.allCases, id: \.self) { trigger in
                                TriggerChip(
                                    trigger: trigger,
                                    isSelected: .init(
                                        get: { viewModel.selectedTriggers.contains(trigger) },
                                        set: { isSelected in
                                            if isSelected {
                                                viewModel.selectedTriggers.insert(trigger)
                                            } else {
                                                viewModel.selectedTriggers.remove(trigger)
                                            }
                                        }
                                    ),
                                    intensity: .constant(nil)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Notes Toggle
                    Button(action: { showNotes.toggle() }) {
                        Label(showNotes ? "Hide notes" : "Add notes", systemImage: showNotes ? "chevron.up" : "chevron.down")
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    
                    if showNotes {
                        TextField("Optional notes...", text: $viewModel.notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Log Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.configure(modelContext: modelContext)
                        viewModel.saveLogs()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                viewModel.configure(modelContext: modelContext)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// Simple flow layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, 
                                       y: bounds.minY + result.positions[index].y), 
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}
