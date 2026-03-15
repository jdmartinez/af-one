import SwiftUI

struct TestTabView: View {
    var body: some View {
        TabView {
            Tab("Test", systemImage: "house") {
                Text("Hello")
            }
        }
    }
}