import Foundation

struct NetworkClient: Sendable {
    private let transport: any HTTPTransport
    private let baseURL: URL

    nonisolated init(
        transport: any HTTPTransport = URLSession.shared,
        baseURL: URL = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com")!
    ) {
        self.transport = transport
        self.baseURL   = baseURL
    }

    nonisolated func request<T: Decodable & Sendable>(_ route: APIRouter) async throws -> T {
        let urlRequest: URLRequest
        do {
            urlRequest = try route.urlRequest(baseURL: baseURL)
        } catch {
            throw NetworkError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: urlRequest)
        } catch {
            throw NetworkError.transportError(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
