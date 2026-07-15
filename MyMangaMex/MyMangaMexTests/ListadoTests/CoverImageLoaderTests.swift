import Testing
@testable import MyMangaMex
import Foundation

// MARK: — Transportes mock

private struct SuccessImageTransport: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let fakeData = Data([0x89, 0x50, 0x4E, 0x47]) // cabecera PNG mínima
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (fakeData, r)
    }
}

private struct FailureImageTransport: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.networkConnectionLost)
    }
}

// MARK: — Tests

@Suite("CoverImageLoader — estados de carga de portada")
@MainActor
struct CoverImageLoaderTests {

    // Tarea 4.A.3 — estado inicial

    @Test("estado inicial es .loading")
    func initialStateIsLoading() {
        let loader = CoverImageLoader(urlString: "https://cdn.example.com/cover.jpg")
        #expect(loader.state == .loading)
    }

    // Tarea 4.A.3 — estado fallback

    @Test("URL nil produce .failed")
    func nilURLProducesFailed() async {
        let loader = CoverImageLoader(urlString: nil)
        await loader.load()
        #expect(loader.state == .failed)
    }

    @Test("URL con formato inválido produce .failed")
    func invalidURLProducesFailed() async {
        let loader = CoverImageLoader(urlString: "no es una url válida :// !")
        await loader.load()
        #expect(loader.state == .failed)
    }

    @Test("error de red produce .failed")
    func networkErrorProducesFailed() async {
        let loader = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: FailureImageTransport()
        )
        await loader.load()
        #expect(loader.state == .failed)
    }

    // Tarea 4.A.3 — estado cargado

    @Test("carga exitosa produce .loaded")
    func successfulLoadProducesLoaded() async {
        let loader = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: SuccessImageTransport()
        )
        await loader.load()
        #expect(loader.state == .loaded)
    }
}
