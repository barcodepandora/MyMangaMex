import Foundation
import Observation

@Observable @MainActor
final class MangaListViewModel {
    private(set) var mangas: [MangaDTO] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var filter: MangaFilter = .none
    private(set) var hasMore = true

    private let client: NetworkClient
    private var currentPage = 0
    private var per = 20
    private var isLoadingPage = false
    private var loadedPages: Set<Int> = []
    private var generation = 0

    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    func loadFirstPage() async {
        generation += 1
        let gen = generation
        isLoadingPage = false
        loadedPages = []
        mangas = []
        currentPage = 0
        hasMore = true
        errorMessage = nil
        await loadNextPage(generation: gen)
    }

    func loadNextPageIfNeeded(currentIndex: Int) async {
        let threshold = Int(Double(mangas.count) * 0.75)
        guard currentIndex >= threshold, hasMore, !isLoadingPage else { return }
        await loadNextPage(generation: generation)
    }

    func applyFilter(_ newFilter: MangaFilter) async {
        filter = newFilter
        await loadFirstPage()
    }

    private func loadNextPage(generation gen: Int) async {
        guard !isLoadingPage, hasMore else { return }
        let nextPage = currentPage + 1
        guard !loadedPages.contains(nextPage) else { return }

        isLoadingPage = true
        isLoading = true
        defer {
            isLoadingPage = false
            isLoading = false
        }

        do {
            let route = routeForCurrentFilter(page: nextPage)
            let page: Page<MangaDTO> = try await client.request(route)
            guard generation == gen else { return }
            loadedPages.insert(nextPage)
            currentPage = nextPage
            per = page.metadata.per
            mangas += page.items
            hasMore = mangas.count < page.metadata.total
        } catch {
            guard generation == gen else { return }
            errorMessage = error.localizedDescription
        }
    }

    private func routeForCurrentFilter(page: Int) -> APIRouter {
        switch filter {
        case .none:
            return .listMangas(page: page, per: per)
        case .byGenre(let g):
            return .listMangasByGenre(g)
        case .byDemographic(let d):
            return .listMangasByDemographic(d)
        case .byTheme(let t):
            return .listMangasByTheme(t)
        }
    }
}
