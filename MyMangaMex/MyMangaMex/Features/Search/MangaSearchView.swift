import SwiftUI

struct MangaSearchView: View {
    var coordinator: AppCoordinator
    @State private var viewModel = MangaSearchViewModel()
    @State private var searchTab: SearchTab = .mangas
    @FocusState private var isFieldFocused: Bool

    enum SearchTab { case mangas, autores }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $searchTab) {
                Text("Mangas").tag(SearchTab.mangas)
                Text("Autores").tag(SearchTab.autores)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            if searchTab == .mangas {
                mangasView
            } else {
                autoresView
            }
        }
        .navigationTitle("Búsqueda")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: — Mangas

    private var mangasView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Buscar mangas…", text: Binding(
                    get: { viewModel.query },
                    set: { viewModel.updateQuery($0) }
                ))
                .focused($isFieldFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.updateQuery("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.bottom, 8)

            Picker("Modo", selection: $viewModel.searchMode) {
                Text("Empieza por").tag(SearchMode.beginsWith)
                Text("Contiene").tag(SearchMode.contains)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            mangaResultsList
        }
        .onAppear { isFieldFocused = true }
    }

    private var mangaResultsList: some View {
        Group {
            if viewModel.mangas.isEmpty && !viewModel.isLoading {
                if viewModel.query.isEmpty {
                    ContentUnavailableView(
                        "Escribe para buscar",
                        systemImage: "magnifyingglass",
                        description: Text("Busca por título usando los modos «empieza por» o «contiene»")
                    )
                } else {
                    ContentUnavailableView.search(text: viewModel.query)
                }
            } else {
                List {
                    ForEach(viewModel.mangas, id: \.id) { manga in
                        SearchMangaRow(manga: manga)
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
            }
        }
    }

    // MARK: — Autores

    private var autoresView: some View {
        AuthorSearchField(viewModel: viewModel)
    }
}

// MARK: — Búsqueda de autores con estado propio

private struct AuthorSearchField: View {
    var viewModel: MangaSearchViewModel
    @State private var authorQuery = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Nombre o apellido…", text: $authorQuery)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        Task { await viewModel.searchAuthors(query: authorQuery) }
                    }
                    .submitLabel(.search)
                if !authorQuery.isEmpty {
                    Button {
                        authorQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onChange(of: authorQuery) {
                if authorQuery.isEmpty { Task { await viewModel.searchAuthors(query: "") } }
            }

            if viewModel.authors.isEmpty {
                ContentUnavailableView(
                    "Busca un autor",
                    systemImage: "person.2",
                    description: Text("Escribe un nombre o apellido y pulsa Buscar")
                )
            } else {
                List(viewModel.authors, id: \.id) { author in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(author.firstName) \(author.lastName)")
                            .font(.headline)
                        Text(author.role)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: — Fila de resultado de manga

private struct SearchMangaRow: View {
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
