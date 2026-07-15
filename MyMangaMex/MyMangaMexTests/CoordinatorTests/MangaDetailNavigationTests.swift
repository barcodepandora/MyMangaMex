import Testing
@testable import MyMangaMex
import Foundation

// MARK: — Mock

private struct SuccessMockTransport: HTTPTransport {
    static let pageJSON = #"{"items":[{"id":1,"title":"Test","status":"Publishing","authors":[],"genres":[],"themes":[],"demographics":[]}],"metadata":{"total":1,"page":1,"per":20}}"#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.pageJSON.utf8), r)
    }
}

private func makeMangaDTO(id: Int = 42) -> MangaDTO {
    let json = "{\"id\":\(id),\"title\":\"Test Manga\",\"status\":\"Publishing\",\"authors\":[],\"genres\":[],\"themes\":[],\"demographics\":[]}"
    return try! JSONDecoder().decode(MangaDTO.self, from: Data(json.utf8))
}

// MARK: — Tests

@Suite("AppCoordinator — Navegación al detalle (Tarea 5.1)")
@MainActor
struct MangaDetailNavigationTests {

    @Test("showMangaDetail expone el manga con el id correcto")
    func showDetailExposesCorrectId() {
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: SuccessMockTransport()),
            splashDuration: .zero
        )
        let manga = makeMangaDTO(id: 42)
        coordinator.showMangaDetail(manga)
        #expect(coordinator.selectedMangaForDetail?.id == 42)
    }

    @Test("selectedMangaForDetail es nil antes de navegar")
    func selectedMangaIsNilInitially() {
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: SuccessMockTransport()),
            splashDuration: .zero
        )
        #expect(coordinator.selectedMangaForDetail == nil)
    }

    @Test("dismissDetail elimina el manga seleccionado")
    func dismissDetailClearsSelection() {
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: SuccessMockTransport()),
            splashDuration: .zero
        )
        coordinator.showMangaDetail(makeMangaDTO(id: 42))
        coordinator.dismissDetail()
        #expect(coordinator.selectedMangaForDetail == nil)
    }
}
