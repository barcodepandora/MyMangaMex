import SwiftUI

struct AppCoordinatorView: View {
    var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.state {
            case .splash:
                SplashView()
            case .loading:
                LoadingView()
            case .listado:
                // Fase 4 implementará MangaListView
                Color.clear
            case .error(let message):
                VStack(spacing: 20) {
                    Text("Error al cargar")
                        .font(.headline)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Reintentar") {
                        Task { await coordinator.retry() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .task { await coordinator.start() }
    }
}
