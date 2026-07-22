import SwiftUI

struct AsyncCoverImage: View {
    @StateObject private var loader: CoverImageLoader

    init(urlString: String?) {
        _loader = StateObject(wrappedValue: CoverImageLoader(urlString: urlString))
    }

    var body: some View {
        Group {
            switch loader.state {
            case .loading:
                placeholder
            case .loaded:
                if let uiImage = loader.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    fallbackView
                }
            case .failed:
                fallbackView
            }
        }
        .task { await loader.load() }
    }

    private var placeholder: some View {
        Color.secondary.opacity(0.12)
            .overlay { ProgressView().scaleEffect(0.7) }
    }

    private var fallbackView: some View {
        Color.secondary.opacity(0.15)
            .overlay {
                Image(systemName: "book.closed")
                    .foregroundStyle(.secondary)
            }
    }
}
