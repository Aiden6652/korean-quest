import SwiftUI

@main
struct KoreanQuestApp: App {
    @StateObject private var store = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @State private var tab: Int = 0

    var body: some View {
        TabView(selection: $tab) {
            MapView()
                .tabItem { Label("闯关", systemImage: "map.fill") }
                .tag(0)
            StatsView()
                .tabItem { Label("进度", systemImage: "chart.bar.fill") }
                .tag(1)
        }
        .tint(KQ.green)
    }
}
