import SwiftUI

@main
struct FarmManagerApp: App {
    @StateObject private var farmStore = FarmStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(farmStore)
                .tint(FarmTheme.green)
        }
    }
}
