import Foundation

enum NetworkError: Error, Sendable {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case transportError(Error)
}
