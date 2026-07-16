import Testing
@testable import MyMangaMex
import Foundation

// MARK: — Transportes mock

private final class CatalogTransport: HTTPTransport, @unchecked Sendable {
    var requests: [URLRequest] = []

    static let genresJSON = #"""
    [{"id":"00000000-0000-0000-0000-000000000001","genre":"Action"},
     {"id":"00000000-0000-0000-0000-000000000002","genre":"Romance"}]
    """#
    static let themesJSON = #"""
    [{"id":"00000000-0000-0000-0000-000000000003","theme":"School"}]
    """#
    static let demographicsJSON = #"""
    [{"id":"00000000-0000-0000-0000-000000000004","demographic":"Shounen"}]
    """#
    static let mangaPageJSON = #"""
    {"items":[{"id":1,"title":"Test Manga","status":"Finished","authors":[],"genres":[],"themes":[],"demographics":[]}],
    "metadata":{"total":10,"page":1,"per":20}}
    """#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let path = request.url?.path ?? ""
        switch true {
        case path.contains("/list/genres"):       return (Data(Self.genresJSON.utf8), r)
        case path.contains("/list/themes"):       return (Data(Self.themesJSON.utf8), r)
        case path.contains("/list/demographics"): return (Data(Self.demographicsJSON.utf8), r)
        default:                                  return (Data(Self.mangaPageJSON.utf8), r)
        }
    }
}

private final class MultiPageAdvancedTransport: HTTPTransport, @unchecked Sendable {
    var callCount = 0
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let page = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "page" })?.value ?? "1"
        let id = page == "1" ? 1 : 2
        let json = """
        {"items":[{"id":\(id),"title":"Advanced \(id)","status":"Finished","authors":[],"genres":[],"themes":[],"demographics":[]}],
        "metadata":{"total":2,"page":\(page),"per":1}}
        """
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(json.utf8), r)
    }
}

private final class RecordingAdvancedTransport: HTTPTransport, @unchecked Sendable {
    var requests: [URLRequest] = []
    var bodies: [Data] = []

    static let mangaPageJSON = #"""
    {"items":[],"metadata":{"total":0,"page":1,"per":20}}
    """#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        if let body = request.httpBody { bodies.append(body) }
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.mangaPageJSON.utf8), r)
    }
}

// MARK: — Tests

@Suite("AdvancedSearchViewModel — Búsqueda avanzada POST")
@MainActor
struct AdvancedSearchViewModelTests {

    // MARK: Tarea 6.B.1 — buildCustomSearch desde el formulario

    @Test("formulario con solo género poblado produce CustomSearch con ese género y el resto nil")
    func buildWithGenreOnly() {
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: CatalogTransport()))
        vm.selectedGenres = ["Action"]
        vm.searchContains = true

        let cs = vm.buildCustomSearch()

        #expect(cs != nil)
        #expect(cs?.searchGenres == ["Action"])
        #expect(cs?.searchContains == true)
        #expect(cs?.searchTitle == nil)
        #expect(cs?.searchAuthorFirstName == nil)
        #expect(cs?.searchAuthorLastName == nil)
        #expect(cs?.searchThemes == nil)
        #expect(cs?.searchDemographics == nil)
    }

    @Test("formulario con título, género y demografía produce CustomSearch con esos tres campos")
    func buildWithMultipleCriteria() {
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: CatalogTransport()))
        vm.title = "Dragon"
        vm.selectedGenres = ["Action"]
        vm.selectedDemographics = ["Shounen"]
        vm.searchContains = false

        let cs = vm.buildCustomSearch()

        #expect(cs?.searchTitle == "Dragon")
        #expect(cs?.searchGenres == ["Action"])
        #expect(cs?.searchDemographics == ["Shounen"])
        #expect(cs?.searchThemes == nil)
        #expect(cs?.searchContains == false)
    }

    @Test("título con solo espacios se considera campo vacío")
    func titleWhitespaceConsideredEmpty() {
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: CatalogTransport()))
        vm.title = "   "

        let cs = vm.buildCustomSearch()

        #expect(cs == nil)
    }

    // MARK: Tarea 6.B.2 — Validación "al menos un criterio"

    @Test("formulario vacío establece validationError y no dispara petición de red")
    func emptyFormSetsValidationError() async {
        let transport = RecordingAdvancedTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))

        await vm.search()

        #expect(vm.validationError != nil)
        #expect(transport.requests.isEmpty)
    }

    @Test("formulario válido limpia el validationError previo")
    func validFormClearsError() async {
        let transport = CatalogTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))

        await vm.search()
        #expect(vm.validationError != nil)

        vm.title = "Dragon"
        await vm.search()

        #expect(vm.validationError == nil)
    }

    @Test("formulario válido dispara exactamente una petición POST a /search/manga")
    func validFormFiresPostRequest() async {
        let transport = RecordingAdvancedTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))
        vm.title = "Dragon"

        await vm.search()

        #expect(transport.requests.count == 1)
        #expect(transport.requests.first?.url?.path == "/search/manga")
        #expect(transport.requests.first?.httpMethod == "POST")
    }

    // MARK: Tarea 6.B.3 — Carga de catálogo desde API

    @Test("loadCatalog puebla géneros, temáticas y demografías desde la API, no hardcodeados")
    func loadCatalogFromAPI() async {
        let transport = CatalogTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))

        await vm.loadCatalog()

        #expect(vm.availableGenres.map(\.genre).contains("Action"))
        #expect(vm.availableGenres.map(\.genre).contains("Romance"))
        #expect(vm.availableThemes.map(\.theme).contains("School"))
        #expect(vm.availableDemographics.map(\.demographic).contains("Shounen"))

        let catalogRequests = transport.requests.filter {
            let p = $0.url?.path ?? ""
            return p.contains("/list/genres") || p.contains("/list/themes") || p.contains("/list/demographics")
        }
        #expect(catalogRequests.count == 3)
    }

    @Test("loadCatalog no repite peticiones si ya se cargó en la misma sesión")
    func catalogCachedAfterFirstLoad() async {
        let transport = CatalogTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))

        await vm.loadCatalog()
        let countAfterFirst = transport.requests.count

        await vm.loadCatalog()

        #expect(transport.requests.count == countAfterFirst, "Segunda llamada no debe generar nuevas peticiones")
    }

    // MARK: Tarea 6.B.4 — Resultados paginados

    @Test("índice al 75% de resultados avanzados dispara la página siguiente")
    func advancedSearchScrollThreshold() async {
        let transport = MultiPageAdvancedTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))
        vm.title = "Dragon"

        await vm.search()
        let countAfterPage1 = vm.mangas.count

        await vm.loadNextPageIfNeeded(currentIndex: 0)

        #expect(vm.mangas.count > countAfterPage1)
        #expect(transport.callCount == 2)
    }

    @Test("nueva búsqueda avanzada reinicia la paginación desde cero")
    func newSearchResetsResults() async {
        let transport = CatalogTransport()
        let vm = AdvancedSearchViewModel(client: NetworkClient(transport: transport))

        vm.title = "Dragon"
        await vm.search()
        let countFirst = vm.mangas.count

        vm.title = "Naruto"
        await vm.search()

        #expect(vm.mangas.count == countFirst, "nueva búsqueda reinicia, no acumula")
    }
}
