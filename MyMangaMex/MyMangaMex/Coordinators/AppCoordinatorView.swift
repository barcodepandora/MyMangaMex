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
                NavigationStack {
                    MangaListView(coordinator: coordinator)
                        .navigationDestination(isPresented: Binding(
                            get: { coordinator.selectedMangaForDetail != nil },
                            set: { if !$0 { coordinator.dismissDetail() } }
                        )) {
                            if let manga = coordinator.selectedMangaForDetail {
                                MangaDetailView(manga: manga)
                            }
                        }
                        .navigationDestination(isPresented: Binding(
                            get: { coordinator.isSearchActive },
                            set: { if !$0 { coordinator.dismissSearch() } }
                        )) {
                            MangaSearchView(coordinator: coordinator)
                        }
                }
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
