import SwiftUI
import SwiftData

@main
struct MyMangaMexApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
        }
        .modelContainer(for: MangaCollectionEntry.self)
    }
}
