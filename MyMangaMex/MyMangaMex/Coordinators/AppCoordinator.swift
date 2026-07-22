import Foundation
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var state: AppState = .splash
    @Published private(set) var selectedMangaForDetail: MangaDTO?
    @Published private(set) var isSearchActive = false

    private let client: NetworkClient
    private let splashDuration: Duration

    init(
        client: NetworkClient = NetworkClient(),
        splashDuration: Duration = .seconds(2)
    ) {
        self.client = client
        self.splashDuration = splashDuration
    }

    func start() async {
        guard case .splash = state else { return }
        try? await Task.sleep(for: splashDuration)
        await load()
    }

    func retry() async {
        await load()
    }

    func showMangaDetail(_ manga: MangaDTO) {
        selectedMangaForDetail = manga
    }

    func dismissDetail() {
        selectedMangaForDetail = nil
    }

    func showSearch() {
        isSearchActive = true
    }

    func dismissSearch() {
        isSearchActive = false
    }

    private func load() async {
        state = .loading
        do {
            let page: Page<MangaDTO> = try await client.request(.listMangas(page: 1, per: 20))
            state = .listado(page)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
