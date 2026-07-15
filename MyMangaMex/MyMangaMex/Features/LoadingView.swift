import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                AppLogoView()
                ProgressView()
                    .controlSize(.large)
            }
        }
    }
}
