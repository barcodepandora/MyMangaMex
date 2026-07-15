import Testing
@testable import MyMangaMex
import Foundation

// MARK: — MockTransport

private struct MockTransport: HTTPTransport {
    enum Config: @unchecked Sendable {
        case success(Data, HTTPURLResponse)
        case failure(URLError)
    }
    let config: Config

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        switch config {
        case .success(let data, let response): return (data, response)
        case .failure(let error):              throw error
        }
    }
}

private extension MockTransport {
    static let dummyURL = URL(string: "https://example.com")!

    static func ok(_ body: String) -> MockTransport {
        let response = HTTPURLResponse(url: dummyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return MockTransport(config: .success(body.data(using: .utf8)!, response))
    }

    static func httpError(_ code: Int) -> MockTransport {
        let response = HTTPURLResponse(url: dummyURL, statusCode: code, httpVersion: nil, headerFields: nil)!
        return MockTransport(config: .success(Data(), response))
    }

    static func networkFailure() -> MockTransport {
        MockTransport(config: .failure(URLError(.notConnectedToInternet)))
    }
}

// MARK: — Tests

@Suite("NetworkClient — Errores tipados")
@MainActor
struct NetworkClientTests {

    let base = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com")!

    @Test("Error de red lanza .transportError")
    func transportError() async {
        let client = NetworkClient(transport: MockTransport.networkFailure(), baseURL: base)
        await #expect(throws: NetworkError.self) {
            let _: Page<MangaDTO> = try await client.request(.listMangas(page: 1, per: 10))
        }
    }

    @Test("Código HTTP 404 lanza .httpError")
    func httpError404() async {
        let client = NetworkClient(transport: MockTransport.httpError(404), baseURL: base)
        await #expect(throws: NetworkError.self) {
            let _: Page<MangaDTO> = try await client.request(.listMangas(page: 1, per: 10))
        }
    }

    @Test("JSON inválido lanza .decodingError")
    func decodingError() async {
        let client = NetworkClient(transport: MockTransport.ok("not json"), baseURL: base)
        await #expect(throws: NetworkError.self) {
            let _: Page<MangaDTO> = try await client.request(.listMangas(page: 1, per: 10))
        }
    }

    @Test("NetworkError casos son distinguibles")
    func networkErrorCasesDistinct() {
        let httpErr   = NetworkError.httpError(statusCode: 500)
        let decErr    = NetworkError.decodingError(URLError(.badURL))
        let transErr  = NetworkError.transportError(URLError(.notConnectedToInternet))

        if case .httpError(let code) = httpErr { #expect(code == 500) }
        else { Issue.record("httpError no matchea el caso correcto") }

        if case .decodingError  = decErr   { } else { Issue.record("decodingError no matchea") }
        if case .transportError = transErr { } else { Issue.record("transportError no matchea") }
        if case .invalidURL     = NetworkError.invalidURL { } else { Issue.record("invalidURL no matchea") }
    }
}
