import Foundation
import Combine

@MainActor
final class CoverImageLoader: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded
        case failed
    }

    @Published private(set) var state: State = .loading
    private let urlString: String?
    private let transport: any HTTPTransport

    init(urlString: String?, transport: any HTTPTransport = URLSession.shared) {
        self.urlString = urlString
        self.transport = transport
    }

    func load() async {
        guard let urlString, let url = URL(string: urlString) else {
            state = .failed
            return
        }
        do {
            let (data, _) = try await transport.data(for: URLRequest(url: url))
            state = data.isEmpty ? .failed : .loaded
        } catch {
            state = .failed
        }
    }
}
