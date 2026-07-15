import SwiftUI

struct AppLogoView: View {
    var body: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .foregroundStyle(Color.accentColor)
    }
}
