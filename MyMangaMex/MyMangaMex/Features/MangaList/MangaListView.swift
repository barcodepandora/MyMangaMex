import SwiftUI

struct MangaListView: View {
    @State private var viewModel: MangaListViewModel
    var coordinator: AppCoordinator

    init(viewModel: MangaListViewModel = MangaListViewModel(), coordinator: AppCoordinator) {
        _viewModel = State(wrappedValue: viewModel)
        self.coordinator = coordinator
    }

    var body: some View {
        List {
            ForEach(viewModel.mangas, id: \.id) { manga in
                MangaRowView(manga: manga)
                    .contentShape(Rectangle())
                    .onTapGesture { coordinator.showMangaDetail(manga) }
                    .onAppear {
                        if let idx = viewModel.mangas.firstIndex(where: { $0.id == manga.id }) {
                            Task { await viewModel.loadNextPageIfNeeded(currentIndex: idx) }
                        }
                    }
            }

            if viewModel.isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Mangas")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.showSearch()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                MangaFilterMenu(viewModel: viewModel)
            }
        }
        .overlay {
            if viewModel.mangas.isEmpty && !viewModel.isLoading {
                if let error = viewModel.errorMessage {
                    ContentUnavailableView(error, systemImage: "wifi.slash")
                } else {
                    ProgressView("Cargando…")
                }
            }
        }
        .task { await viewModel.loadFirstPage() }
    }
}

// MARK: — Fila de manga

private struct MangaRowView: View {
    let manga: MangaDTO

    var body: some View {
        HStack(spacing: 12) {
            AsyncCoverImage(urlString: manga.mainPicture)
                .frame(width: 56, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.titleEnglish ?? manga.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(manga.status.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let score = manga.score {
                    Label(String(format: "%.2f", score), systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: — Menú de filtro

private struct MangaFilterMenu: View {
    var viewModel: MangaListViewModel

    private let genres     = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Horror", "Mystery", "Romance", "Sci-Fi", "Slice of Life"]
    private let demographics = ["Shounen", "Shoujo", "Seinen", "Josei"]
    private let themes     = ["School", "Martial Arts", "Super Power", "Music", "Sports", "Historical"]

    var body: some View {
        Menu {
            Button {
                Task { await viewModel.applyFilter(.none) }
            } label: {
                Label("Sin filtro", systemImage: "xmark.circle")
            }

            Menu("Por género") {
                ForEach(genres, id: \.self) { g in
                    Button(g) { Task { await viewModel.applyFilter(.byGenre(g)) } }
                }
            }

            Menu("Por demografía") {
                ForEach(demographics, id: \.self) { d in
                    Button(d) { Task { await viewModel.applyFilter(.byDemographic(d)) } }
                }
            }

            Menu("Por temática") {
                ForEach(themes, id: \.self) { t in
                    Button(t) { Task { await viewModel.applyFilter(.byTheme(t)) } }
                }
            }
        } label: {
            Image(systemName: viewModel.filter == .none
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
    }
}
