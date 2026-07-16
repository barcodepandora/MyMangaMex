import Foundation
import Observation

@Observable @MainActor
final class MangaSearchViewModel {
    private(set) var mangas: [MangaDTO] = []
    private(set) var authors: [AuthorDTO] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var hasMore = true

    var searchMode: SearchMode = .beginsWith {
        didSet {
            guard searchMode != oldValue, !currentQuery.isEmpty else { return }
            triggerSearch(query: currentQuery)
        }
    }

    static let defaultDebounceInterval: Duration = .milliseconds(400)
    static let defaultPer = 20

    private let client: NetworkClient
    private let debounceInterval: Duration
    private var debounceTask: Task<Void, Never>?
    private var currentQuery = ""
    private var currentPage = 0
    private var per = defaultPer
    private var isLoadingPage = false
    private var loadedPages: Set<Int> = []
    private var generation = 0

    init(client: NetworkClient = NetworkClient(), debounceInterval: Duration = defaultDebounceInterval) {
        self.client = client
        self.debounceInterval = debounceInterval
    }

    func updateQuery(_ text: String) {
        currentQuery = text
        debounceTask?.cancel()
        guard !text.isEmpty else {
            mangas = []
            hasMore = false
            return
        }
        triggerSearch(query: text)
    }

    func loadNextPageIfNeeded(currentIndex: Int) async {
        let threshold = Int(Double(mangas.count) * 0.75)
        guard currentIndex >= threshold, hasMore, !isLoadingPage else { return }
        await loadNextPage(generation: generation)
    }

    func searchAuthors(query: String) async {
        guard !query.isEmpty else {
            authors = []
            return
        }
        do {
            authors = try await client.request(.searchAuthor(query))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: — Private

    private func triggerSearch(query: String) {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: debounceInterval)
            guard !Task.isCancelled else { return }
            await resetAndLoad(query: query)
        }
    }

    private func resetAndLoad(query: String) async {
        generation += 1
        let gen = generation
        isLoadingPage = false
        loadedPages = []
        mangas = []
        currentPage = 0
        hasMore = true
        errorMessage = nil
        per = Self.defaultPer
        await loadNextPage(generation: gen)
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

        let query = currentQuery
        guard !query.isEmpty else { return }

        do {
            let route = routeForCurrentMode(query: query, page: nextPage)
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

    private func routeForCurrentMode(query: String, page: Int) -> APIRouter {
        switch searchMode {
        case .beginsWith: return .searchMangasBeginsWith(query, page: page, per: per)
        case .contains:   return .searchMangasContains(query, page: page, per: per)
        }
    }
}
