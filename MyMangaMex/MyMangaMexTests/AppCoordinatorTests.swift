import Testing
@testable import MyMangaMex

@Suite("AppCoordinator")
struct AppCoordinatorTests {

    @Test("AppCoordinator puede instanciarse en MainActor")
    @MainActor
    func appCoordinatorExiste() {
        let _ = AppCoordinator()
    }
}
