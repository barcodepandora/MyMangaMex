import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                AppLogoView()
                Text("My Manga Mex")
                    .font(.largeTitle.bold())
            }
        }
    }
}
