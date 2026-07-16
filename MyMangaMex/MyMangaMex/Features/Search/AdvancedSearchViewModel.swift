import Foundation
import Combine

@MainActor
final class AdvancedSearchViewModel: ObservableObject {

    // MARK: — Form state
    @Published var title: String = ""
    @Published var authorFirstName: String = ""
    @Published var authorLastName: String = ""
    @Published var selectedGenres: Set<String> = []
    @Published var selectedThemes: Set<String> = []
    @Published var selectedDemographics: Set<String> = []
    @Published var searchContains: Bool = false

    // MARK: — Catalog (session-cached)
    @Published private(set) var availableGenres: [GenreDTO] = []
    @Published private(set) var availableThemes: [ThemeDTO] = []
    @Published private(set) var availableDemographics: [DemographicDTO] = []
    private var catalogLoaded = false

    // MARK: — Results
    @Published private(set) var mangas: [MangaDTO] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMore = true
    @Published private(set) var validationError: String?

    // MARK: — Pagination state
    private var currentPage = 0
    private var per = 20
    private var isLoadingPage = false
    private var loadedPages: Set<Int> = []
    private var generation = 0

    private let client: NetworkClient

    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    // MARK: — Public API

    func buildCustomSearch() -> CustomSearch? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedFirst = authorFirstName.trimmingCharacters(in: .whitespaces)
        let trimmedLast  = authorLastName.trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty || !trimmedFirst.isEmpty || !trimmedLast.isEmpty
                || !selectedGenres.isEmpty || !selectedThemes.isEmpty || !selectedDemographics.isEmpty
        else { return nil }

        return CustomSearch(
            searchTitle:           trimmedTitle.isEmpty ? nil : trimmedTitle,
            searchAuthorFirstName: trimmedFirst.isEmpty ? nil : trimmedFirst,
            searchAuthorLastName:  trimmedLast.isEmpty  ? nil : trimmedLast,
            searchGenres:          selectedGenres.isEmpty      ? nil : Array(selectedGenres),
            searchThemes:          selectedThemes.isEmpty      ? nil : Array(selectedThemes),
            searchDemographics:    selectedDemographics.isEmpty ? nil : Array(selectedDemographics),
            searchContains:        searchContains
        )
    }

    func search() async {
        guard let customSearch = buildCustomSearch() else {
            validationError = "Introduce al menos un criterio de búsqueda"
            return
        }
        validationError = nil
        generation += 1
        let gen = generation
        isLoadingPage = false
        loadedPages = []
        mangas = []
        currentPage = 0
        hasMore = true
        per = 20
        await loadNextPage(search: customSearch, generation: gen)
    }

    func loadNextPageIfNeeded(currentIndex: Int) async {
        let threshold = Int(Double(mangas.count) * 0.75)
        guard currentIndex >= threshold, hasMore, !isLoadingPage else { return }
        guard let cs = buildCustomSearch() else { return }
        await loadNextPage(search: cs, generation: generation)
    }

    func loadCatalog() async {
        guard !catalogLoaded else { return }
        async let genres: [GenreDTO]       = (try? client.request(.listGenres))       ?? []
        async let themes: [ThemeDTO]       = (try? client.request(.listThemes))       ?? []
        async let demos: [DemographicDTO]  = (try? client.request(.listDemographics)) ?? []
        availableGenres       = await genres
        availableThemes       = await themes
        availableDemographics = await demos
        catalogLoaded = true
    }

    // MARK: — Private

    private func loadNextPage(search: CustomSearch, generation gen: Int) async {
        guard !isLoadingPage, hasMore else { return }
        let nextPage = currentPage + 1
        guard !loadedPages.contains(nextPage) else { return }

        isLoadingPage = true
        isLoading = true
        defer { isLoadingPage = false; isLoading = false }

        do {
            let page: Page<MangaDTO> = try await client.request(
                .searchMangaAdvanced(search, page: nextPage, per: per)
            )
            guard generation == gen else { return }
            loadedPages.insert(nextPage)
            currentPage = nextPage
            per = page.metadata.per
            mangas += page.items
            hasMore = mangas.count < page.metadata.total
        } catch {
            guard generation == gen else { return }
        }
    }
}
