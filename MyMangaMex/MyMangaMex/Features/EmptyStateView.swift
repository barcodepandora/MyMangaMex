import SwiftUI

/// Reemplazo de ContentUnavailableView (iOS 17+) compatible con iOS 16
struct EmptyStateView: View {
    let title: String
    let systemImage: String
    var description: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            if let description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
