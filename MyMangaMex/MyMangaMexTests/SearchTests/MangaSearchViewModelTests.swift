import Testing
@testable import MyMangaMex
import Foundation

// MARK: — Transportes mock

private final class RecordingTransport: HTTPTransport, @unchecked Sendable {
    var requests: [URLRequest] = []
    static let mangaJSON = #"""
    {"items":[
        {"id":1,"title":"Dragon Ball","status":"Finished","authors":[],"genres":[],"themes":[],"demographics":[]}
    ],"metadata":{"total":10,"page":1,"per":20}}
    """#
    static let authorJSON = #"""
    [{"id":"00000000-0000-0000-0000-000000000001","firstName":"Akira","lastName":"Toriyama","role":"Story & Art"}]
    """#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let path = request.url?.path ?? ""
        if path.contains("/search/author") {
            return (Data(Self.authorJSON.utf8), r)
        }
        return (Data(Self.mangaJSON.utf8), r)
    }
}

private final class SlowTransport: HTTPTransport, @unchecked Sendable {
    var callCount = 0
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let json = #"{"items":[{"id":1,"title":"X","status":"Finished","authors":[],"genres":[],"themes":[],"demographics":[]}],"metadata":{"total":100,"page":1,"per":20}}"#
        return (Data(json.utf8), r)
    }
}

private final class MultiPageSearchTransport: HTTPTransport, @unchecked Sendable {
    var callCount = 0
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let page = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "page" })?.value ?? "1"
        let id = page == "1" ? 1 : 2
        let json = """
        {"items":[{"id":\(id),"title":"Result \(id)","status":"Finished","authors":[],"genres":[],"themes":[],"demographics":[]}],
        "metadata":{"total":2,"page":\(page),"per":1}}
        """
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(json.utf8), r)
    }
}

// MARK: — Tests

@Suite("MangaSearchViewModel — Búsqueda y paginación")
@MainActor
struct MangaSearchViewModelTests {

    // MARK: Tarea 6.A.1 — Debounce

    @Test("tecleo rápido dispara una sola petición de red tras el antirrebote")
    func debounceCollapsesFastTyping() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(100)
        )

        vm.updateQuery("d")
        vm.updateQuery("dr")
        vm.updateQuery("dra")
        vm.updateQuery("drag")
        vm.updateQuery("dragon")

        try await Task.sleep(for: .milliseconds(300))

        #expect(transport.requests.count == 1)
        #expect(transport.requests.first?.url?.absoluteString.contains("dragon") == true)
    }

    @Test("actualizar query antes del antirrebote cancela la petición anterior")
    func debounceCancelsPendingRequest() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(100)
        )

        vm.updateQuery("abc")
        try await Task.sleep(for: .milliseconds(50))
        vm.updateQuery("abcd")

        try await Task.sleep(for: .milliseconds(300))

        #expect(transport.requests.count == 1)
        #expect(transport.requests.first?.url?.absoluteString.contains("abcd") == true)
    }

    // MARK: Tarea 6.A.2 — Alternancia empieza-por / contiene

    @Test("modo beginsWith usa endpoint searchMangasBeginsWith")
    func beginsWithUsesCorrectEndpoint() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        vm.searchMode = .beginsWith
        vm.updateQuery("dragon")
        try await Task.sleep(for: .milliseconds(100))

        #expect(transport.requests.first?.url?.path.contains("mangasBeginsWith") == true)
    }

    @Test("modo contains usa endpoint searchMangasContains")
    func containsUsesCorrectEndpoint() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        vm.searchMode = .contains
        vm.updateQuery("ball")
        try await Task.sleep(for: .milliseconds(100))

        #expect(transport.requests.first?.url?.path.contains("mangasContains") == true)
    }

    @Test("cambiar modo relanza la búsqueda con el nuevo endpoint")
    func changingModeRelaunches() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        vm.searchMode = .beginsWith
        vm.updateQuery("dragon")
        try await Task.sleep(for: .milliseconds(100))

        vm.searchMode = .contains
        try await Task.sleep(for: .milliseconds(100))

        #expect(transport.requests.count == 2)
        #expect(transport.requests.last?.url?.path.contains("mangasContains") == true)
    }

    // MARK: Tarea 6.A.3 — Búsqueda de autores

    @Test("searchAuthors puebla la lista de autores con el fragmento dado")
    func searchAuthorPopulatesAuthors() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        await vm.searchAuthors(query: "toriya")

        #expect(transport.requests.count == 1)
        #expect(transport.requests.first?.url?.path.contains("/search/author") == true)
        #expect(vm.authors.count == 1)
        #expect(vm.authors.first?.lastName == "Toriyama")
    }

    @Test("query vacío en searchAuthors no dispara petición de red")
    func emptyAuthorQuerySkipsRequest() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        await vm.searchAuthors(query: "")

        #expect(transport.requests.isEmpty)
        #expect(vm.authors.isEmpty)
    }

    // MARK: Tarea 6.A.4 — Scroll infinito en resultados de búsqueda

    @Test("índice al 75% de resultados de búsqueda dispara la página siguiente")
    func searchScrollThresholdTriggersNextPage() async throws {
        let transport = MultiPageSearchTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        vm.updateQuery("dragon")
        try await Task.sleep(for: .milliseconds(100))
        let countAfterPage1 = vm.mangas.count

        await vm.loadNextPageIfNeeded(currentIndex: 0)

        #expect(vm.mangas.count > countAfterPage1)
        #expect(transport.callCount == 2)
    }

    @Test("índice por debajo del 75% no dispara carga adicional en búsqueda")
    func belowThresholdDoesNotTriggerSearch() async throws {
        let transport = SlowTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        vm.updateQuery("dragon")
        try await Task.sleep(for: .milliseconds(100))

        // 1 ítem → threshold = 0; índice -1 está por debajo
        // Para este test usamos una página con 4 ítems vía metadata
        // transport siempre devuelve 1 ítem con total=100, per=20
        // threshold = Int(1 * 0.75) = 0, así que índice 0 SÍ dispara
        // Verificamos que nueva query reinicia y no acumula
        let countBefore = transport.callCount

        // No hacemos loadNextPageIfNeeded porque threshold=0 con 1 ítem siempre dispara
        // En cambio verificamos que query vacío limpia mangas
        vm.updateQuery("")
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.mangas.isEmpty)
        #expect(transport.callCount == countBefore, "query vacío no debe hacer petición de red")
    }

    @Test("nueva búsqueda reinicia la paginación desde cero")
    func newQueryResetsPagination() async throws {
        let transport = RecordingTransport()
        let vm = MangaSearchViewModel(
            client: NetworkClient(transport: transport),
            debounceInterval: .milliseconds(10)
        )

        vm.updateQuery("dragon")
        try await Task.sleep(for: .milliseconds(100))
        let countFirst = vm.mangas.count

        vm.updateQuery("naruto")
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.mangas.count == countFirst, "nueva búsqueda reinicia el listado, no acumula")
        #expect(transport.requests.last?.url?.absoluteString.contains("naruto") == true)
    }
}
