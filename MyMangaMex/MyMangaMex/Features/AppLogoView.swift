import SwiftUI

struct AppLogoView: View {
    var body: some View {
        Image(systemName: "star.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .foregroundStyle(Color.accentColor)
    }
}
