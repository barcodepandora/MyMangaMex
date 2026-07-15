import SwiftUI

struct AsyncCoverImage: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    fallbackView
                @unknown default:
                    fallbackView
                }
            }
        } else {
            fallbackView
        }
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
