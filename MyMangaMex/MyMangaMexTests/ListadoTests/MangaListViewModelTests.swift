import Testing
@testable import MyMangaMex
import Foundation

// MARK: — Transportes mock

private struct SinglePageTransport: HTTPTransport {
    static let json = #"""
    {"items":[
        {"id":1,"title":"Manga A","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]},
        {"id":2,"title":"Manga B","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]}
    ],"metadata":{"total":100,"page":1,"per":20}}
    """#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.json.utf8), r)
    }
}

private final class RecordingTransport: HTTPTransport, @unchecked Sendable {
    var requests: [URLRequest] = []
    static let json = #"""
    {"items":[
        {"id":1,"title":"Manga A","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]}
    ],"metadata":{"total":100,"page":1,"per":20}}
    """#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.json.utf8), r)
    }
}

private final class MultiPageTransport: HTTPTransport, @unchecked Sendable {
    var callCount = 0

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let pageNum = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "page" })?.value ?? "1"
        let id    = pageNum == "1" ? 1 : 2
        let title = pageNum == "1" ? "Manga Uno" : "Manga Dos"
        let json = """
        {"items":[{"id":\(id),"title":"\(title)","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]}],
        "metadata":{"total":2,"page":\(pageNum),"per":1}}
        """
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(json.utf8), r)
    }
}

private final class PageOf4Transport: HTTPTransport, @unchecked Sendable {
    var callCount = 0
    static let json = #"""
    {"items":[
        {"id":1,"title":"M1","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]},
        {"id":2,"title":"M2","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]},
        {"id":3,"title":"M3","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]},
        {"id":4,"title":"M4","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]}
    ],"metadata":{"total":100,"page":1,"per":4}}
    """#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.json.utf8), r)
    }
}

// MARK: — Tests

@Suite("MangaListViewModel — Listado y paginación")
@MainActor
struct MangaListViewModelTests {

    // MARK: Tarea 4.A.1 — Carga de primera página

    @Test("mangas está vacío antes de cargar")
    func mangasEmptyBeforeLoad() {
        let vm = MangaListViewModel(client: NetworkClient(transport: SinglePageTransport()))
        #expect(vm.mangas.isEmpty)
    }

    @Test("loadFirstPage puebla el arreglo de mangas")
    func firstPageLoadPopulatesMangas() async {
        let vm = MangaListViewModel(client: NetworkClient(transport: SinglePageTransport()))
        await vm.loadFirstPage()
        #expect(vm.mangas.count == 2)
    }

    @Test("isLoading es false cuando la carga termina")
    func isLoadingFalseAfterLoad() async {
        let vm = MangaListViewModel(client: NetworkClient(transport: SinglePageTransport()))
        await vm.loadFirstPage()
        #expect(vm.isLoading == false)
    }

    // MARK: Tarea 4.A.2 — Consistencia de per entre páginas

    @Test("per se conserva igual entre la primera y segunda página")
    func perIsConsistentAcrossPages() async {
        let transport = RecordingTransport()
        let vm = MangaListViewModel(client: NetworkClient(transport: transport))
        await vm.loadFirstPage()
        // Con 1 ítem y total=100, hasMore=true; threshold=0 → index 0 dispara página 2
        await vm.loadNextPageIfNeeded(currentIndex: 0)

        let perValues = transport.requests.compactMap {
            URLComponents(url: $0.url!, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "per" })?.value
        }
        guard perValues.count >= 2 else {
            Issue.record("Se esperaban al menos 2 peticiones con query `per`; recibidas: \(perValues.count)")
            return
        }
        #expect(Set(perValues).count == 1, "El valor de per debe ser idéntico en todas las páginas")
    }

    // MARK: Tarea 4.B.1 — Umbral del 75%

    @Test("índice al 75% de la lista dispara la carga de la siguiente página")
    func scrollThresholdTriggersNextPage() async {
        let transport = MultiPageTransport()
        let vm = MangaListViewModel(client: NetworkClient(transport: transport))
        await vm.loadFirstPage()
        let countAfterPage1 = vm.mangas.count

        // 1 ítem → threshold = 0; index 0 debería disparar página 2
        await vm.loadNextPageIfNeeded(currentIndex: 0)

        #expect(vm.mangas.count > countAfterPage1, "Cargar la página 2 debe añadir elementos al listado")
    }

    @Test("índice por debajo del 75% no dispara carga adicional")
    func belowThresholdDoesNotTriggerLoad() async {
        let transport = PageOf4Transport()
        let vm = MangaListViewModel(client: NetworkClient(transport: transport))
        await vm.loadFirstPage()
        #expect(vm.mangas.count == 4)

        // threshold = Int(4 * 0.75) = 3 → índice 2 está debajo
        await vm.loadNextPageIfNeeded(currentIndex: 2)
        #expect(transport.callCount == 1, "Índice 2 (por debajo de 75% de 4) no debe disparar petición de red")

        // índice 3 alcanza el umbral → debe disparar
        await vm.loadNextPageIfNeeded(currentIndex: 3)
        #expect(transport.callCount == 2, "Índice 3 (75% de 4) sí debe disparar petición de red")
    }

    // MARK: Tarea 4.B.2 — Sin duplicados en carga incremental

    @Test("total tras dos páginas es la suma exacta sin duplicados")
    func noElementDuplicationAcrossPages() async {
        let transport = MultiPageTransport()
        let vm = MangaListViewModel(client: NetworkClient(transport: transport))

        await vm.loadFirstPage()
        #expect(vm.mangas.count == 1)

        await vm.loadNextPageIfNeeded(currentIndex: 0)
        #expect(vm.mangas.count == 2, "Tras página 2 deben sumarse los ítems, no reemplazarse")

        // Re-disparar con misma condición: hasMore=false y/o página ya cargada
        await vm.loadNextPageIfNeeded(currentIndex: 0)
        #expect(vm.mangas.count == 2, "No debe haber duplicados al re-solicitar la misma condición")
        #expect(transport.callCount == 2, "Solo deben realizarse 2 peticiones de red")
    }

    // MARK: Tarea 4.B.3 — Filtro de categorización

    @Test("aplicar filtro de género usa endpoint de filtro, no el listado general")
    func filterByGenreUsesCorrectEndpoint() async {
        let transport = RecordingTransport()
        let vm = MangaListViewModel(client: NetworkClient(transport: transport))

        await vm.loadFirstPage()                      // → /list/mangas
        await vm.applyFilter(.byGenre("Action"))      // → /list/mangaByGenre/Action

        guard transport.requests.count >= 2 else {
            Issue.record("Se esperaban al menos 2 peticiones; recibidas: \(transport.requests.count)")
            return
        }
        #expect(transport.requests.first?.url?.path.contains("/list/mangas") == true)
        #expect(transport.requests.last?.url?.path.contains("/list/mangaByGenre/Action") == true)
    }

    // MARK: Tarea 4.B.4 — Reinicio al cambiar filtro

    @Test("cambiar filtro reinicia el listado desde cero sin acumular resultados anteriores")
    func filterChangeResetsMangas() async {
        let transport = RecordingTransport()
        let vm = MangaListViewModel(client: NetworkClient(transport: transport))

        await vm.loadFirstPage()
        let countBeforeFilter = vm.mangas.count

        await vm.applyFilter(.byGenre("Romance"))

        // El mock siempre devuelve 1 ítem; tras reset el count debe ser igual, no doble
        #expect(vm.mangas.count == countBeforeFilter,
                "El cambio de filtro debe reiniciar el listado, no acumular resultados")
        #expect(vm.filter == .byGenre("Romance"))
    }
}
