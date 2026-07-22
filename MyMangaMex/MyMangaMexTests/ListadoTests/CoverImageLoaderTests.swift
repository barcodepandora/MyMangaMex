import Testing
@testable import MyMangaMex
import Foundation
import UIKit

// MARK: — Transportes mock

private final class CountingTransport: HTTPTransport, @unchecked Sendable {
    private(set) var callCount = 0

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        let data = UIImage(systemName: "star")!.pngData()!
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, r)
    }
}

private struct SuccessImageTransport: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let data = UIImage(systemName: "star")!.pngData()!
        let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, r)
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

    // Estado inicial

    @Test("estado inicial es .loading")
    func initialStateIsLoading() {
        let loader = CoverImageLoader(urlString: "https://cdn.example.com/cover.jpg")
        #expect(loader.state == .loading)
    }

    // Estados fallback

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
            transport: FailureImageTransport(),
            cache: ImageCache()
        )
        await loader.load()
        #expect(loader.state == .failed)
    }

    // Estado cargado

    @Test("carga exitosa produce .loaded")
    func successfulLoadProducesLoaded() async {
        let loader = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: SuccessImageTransport(),
            cache: ImageCache()
        )
        await loader.load()
        #expect(loader.state == .loaded)
    }

    @Test("carga exitosa expone UIImage no nula")
    func successfulLoadExposesImage() async {
        let loader = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: SuccessImageTransport(),
            cache: ImageCache()
        )
        await loader.load()
        #expect(loader.image != nil)
    }

    // Caché

    @Test("segunda carga con mismo URL no invoca el transporte")
    func secondLoadUsesCache() async {
        let transport = CountingTransport()
        let cache = ImageCache()
        let loader = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: transport,
            cache: cache
        )
        await loader.load()
        await loader.load()
        #expect(transport.callCount == 1)
    }

    @Test("segunda carga con caché produce .loaded sin red")
    func secondLoadFromCacheIsLoaded() async {
        let cache = ImageCache()
        let loader = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: SuccessImageTransport(),
            cache: cache
        )
        await loader.load()
        let loader2 = CoverImageLoader(
            urlString: "https://cdn.example.com/cover.jpg",
            transport: FailureImageTransport(),
            cache: cache
        )
        await loader2.load()
        #expect(loader2.state == .loaded)
        #expect(loader2.image != nil)
    }
}
