import SwiftUI
import CoreData

@main
struct MyMangaMexApp: App {
    private let persistence = PersistenceController.shared
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
