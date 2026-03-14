import SwiftUI

/// Tab item data model for GlassBottomBar
struct TabItem: Identifiable, Equatable {
    let id: Int
    let title: String
    let systemImage: String
}

/// Liquid Glass bottom tab bar with collapse behavior
struct GlassBottomBar: View {
    @Binding var selectedTab: Int
    let isVisible: Bool
    
    private let tabs: [TabItem] = [
        TabItem(id: 0, title: "Dashboard", systemImage: "house.fill"),
        TabItem(id: 1, title: "Timeline", systemImage: "chart.bar.xaxis"),
        TabItem(id: 2, title: "Episodes", systemImage: "heart.circle"),
        TabItem(id: 3, title: "Medications", systemImage: "pills"),
        TabItem(id: 4, title: "Analysis", systemImage: "chart.bar.fill"),
        TabItem(id: 5, title: "Trends", systemImage: "chart.line.uptrend.xyaxis"),
        TabItem(id: 6, title: "More", systemImage: "ellipsis.circle")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                TabItemButton(
                    tab: tab,
                    isSelected: selectedTab == tab.id,
                    action: { selectedTab = tab.id }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(backgroundView)
        .frame(height: 65)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 0) {
                Color.clear
            }
            .background(.ultraThinMaterial)
        } else {
            Color(.systemBackground)
                .opacity(0.85)
                .background(.ultraThinMaterial)
        }
    }
}

/// Individual tab item button
struct TabItemButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Scroll offset tracker preference key
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Scroll tracker modifier for collapse behavior
struct ScrollTrackerModifier: ViewModifier {
    @Binding var offset: CGFloat
    let threshold: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                }
            )
            .onPreferenceChange(ScrollOffsetKey.self) { newValue in
                offset = newValue
            }
    }
}

extension View {
    func scrollTracker(offset: Binding<CGFloat>, threshold: CGFloat = 50) -> some View {
        modifier(ScrollTrackerModifier(offset: offset, threshold: threshold))
    }
}

#Preview {
    VStack {
        Spacer()
        GlassBottomBar(selectedTab: .constant(0), isVisible: true)
    }
    .background(Color(.systemGroupedBackground))
}
