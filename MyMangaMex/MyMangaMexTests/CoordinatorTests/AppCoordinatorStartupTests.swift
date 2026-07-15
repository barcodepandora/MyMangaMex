import Testing
@testable import MyMangaMex
import Foundation

// MARK: — Mock transports

private struct SuccessMockTransport: HTTPTransport {
    static let pageJSON = #"{"items":[{"id":1,"title":"Test","status":"Publishing"}],"metadata":{"total":1,"page":1,"per":20}}"#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.pageJSON.utf8), response)
    }
}

private struct FailureMockTransport: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.notConnectedToInternet)
    }
}

private final class ConfigurableMockTransport: HTTPTransport, @unchecked Sendable {
    var shouldFail = false
    static let pageJSON = #"{"items":[{"id":1,"title":"Test","status":"Publishing"}],"metadata":{"total":1,"page":1,"per":20}}"#

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(Self.pageJSON.utf8), response)
    }
}

// MARK: — Tests

@Suite("AppCoordinator — Arranque")
@MainActor
struct AppCoordinatorStartupTests {

    // Tarea 3.1 — Estado inicial
    @Test("Estado inicial es .splash")
    func initialStateIsSplash() {
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: SuccessMockTransport()),
            splashDuration: .zero
        )
        guard case .splash = coordinator.state else {
            Issue.record("Esperado .splash, obtenido \(coordinator.state)")
            return
        }
    }

    // Tarea 3.2 + 3.3a — splash → loading → listado
    @Test("start() con red OK transiciona a .listado")
    func startSuccessTransitionsToListado() async {
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: SuccessMockTransport()),
            splashDuration: .zero
        )
        await coordinator.start()
        guard case .listado = coordinator.state else {
            Issue.record("Esperado .listado, obtenido \(coordinator.state)")
            return
        }
    }

    // Tarea 3.3b — loading → error
    @Test("start() con red fallida transiciona a .error")
    func startFailureTransitionsToError() async {
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: FailureMockTransport()),
            splashDuration: .zero
        )
        await coordinator.start()
        guard case .error = coordinator.state else {
            Issue.record("Esperado .error, obtenido \(coordinator.state)")
            return
        }
    }

    // Tarea 3.4 — retry desde error
    @Test("retry() desde .error con red OK recupera .listado")
    func retryFromErrorTransitionsToListado() async {
        let transport = ConfigurableMockTransport()
        transport.shouldFail = true
        let coordinator = AppCoordinator(
            client: NetworkClient(transport: transport),
            splashDuration: .zero
        )
        await coordinator.start()
        guard case .error = coordinator.state else {
            Issue.record("Prerrequisito: esperado .error antes de retry")
            return
        }
        transport.shouldFail = false
        await coordinator.retry()
        guard case .listado = coordinator.state else {
            Issue.record("Esperado .listado tras retry, obtenido \(coordinator.state)")
            return
        }
    }
}
