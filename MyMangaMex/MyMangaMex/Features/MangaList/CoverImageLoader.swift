import Foundation
import Combine
import UIKit

@MainActor
final class CoverImageLoader: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded
        case failed
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var image: UIImage?

    private let urlString: String?
    private let transport: any HTTPTransport
    private let cache: ImageCache

    init(urlString: String?, transport: any HTTPTransport = URLSession.shared, cache: ImageCache = .shared) {
        self.urlString = urlString
        self.transport = transport
        self.cache = cache
    }

    func load() async {
        guard let urlString, let url = URL(string: urlString) else {
            state = .failed
            return
        }
        if let cached = cache.image(for: url) {
            image = cached
            state = .loaded
            return
        }
        do {
            let (data, _) = try await transport.data(for: URLRequest(url: url))
            guard !data.isEmpty, let uiImage = UIImage(data: data) else {
                state = .failed
                return
            }
            cache.store(uiImage, for: url)
            image = uiImage
            state = .loaded
        } catch {
            state = .failed
        }
    }
}
