import Foundation
import Combine

@MainActor
final class MangaSearchViewModel: ObservableObject {
    @Published private(set) var mangas: [MangaDTO] = []
    @Published private(set) var authors: [AuthorDTO] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasMore = true

    @Published var searchMode: SearchMode = .beginsWith
    @Published private(set) var query: String = ""

    nonisolated static let defaultDebounceInterval: Duration = .milliseconds(400)
    nonisolated static let defaultPer = 20

    private let client: NetworkClient
    private var searchSubscription: AnyCancellable?
    private var pendingSearchTask: Task<Void, Never>?
    private var currentPage = 0
    private var per = defaultPer
    private var isLoadingPage = false
    private var loadedPages: Set<Int> = []
    private var generation = 0

    init(client: NetworkClient = NetworkClient(), debounceInterval: Duration = defaultDebounceInterval) {
        self.client = client

        let c = debounceInterval.components
        let debounceSeconds = Double(c.seconds) + Double(c.attoseconds) / 1_000_000_000_000_000_000

        // Combine pipeline: cualquier cambio en query o searchMode → debounce → búsqueda
        searchSubscription = Publishers.CombineLatest($query, $searchMode)
            .removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 })
            .debounce(for: .seconds(debounceSeconds), scheduler: DispatchQueue.main)
            .sink { [weak self] query, _ in
                guard let self else { return }
                guard !query.isEmpty else {
                    self.mangas = []
                    self.hasMore = false
                    return
                }
                self.pendingSearchTask?.cancel()
                self.pendingSearchTask = Task { [weak self] in
                    await self?.resetAndLoad()
                }
            }
    }

    func updateQuery(_ text: String) {
        query = text
        if text.isEmpty {
            pendingSearchTask?.cancel()
            mangas = []
            hasMore = false
        }
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

    private func resetAndLoad() async {
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

        let searchQuery = query
        guard !searchQuery.isEmpty else { return }

        do {
            let route = routeForCurrentMode(query: searchQuery, page: nextPage)
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
