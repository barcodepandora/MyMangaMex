import SwiftUI

struct AdvancedSearchView: View {
    var coordinator: AppCoordinator
    @State private var viewModel = AdvancedSearchViewModel()

    var body: some View {
        Form {
            Section("Título") {
                TextField("Ej. Dragon Ball", text: $viewModel.title)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Section("Autor") {
                TextField("Nombre", text: $viewModel.authorFirstName)
                    .autocorrectionDisabled()
                TextField("Apellido", text: $viewModel.authorLastName)
                    .autocorrectionDisabled()
            }

            Section("Géneros") {
                if viewModel.availableGenres.isEmpty {
                    ProgressView("Cargando…")
                } else {
                    ForEach(viewModel.availableGenres, id: \.id) { g in
                        MultiSelectRow(
                            label: g.genre,
                            isSelected: viewModel.selectedGenres.contains(g.genre)
                        ) {
                            viewModel.selectedGenres.toggle(g.genre)
                        }
                    }
                }
            }

            Section("Temáticas") {
                ForEach(viewModel.availableThemes, id: \.id) { t in
                    MultiSelectRow(
                        label: t.theme,
                        isSelected: viewModel.selectedThemes.contains(t.theme)
                    ) {
                        viewModel.selectedThemes.toggle(t.theme)
                    }
                }
            }

            Section("Demografías") {
                ForEach(viewModel.availableDemographics, id: \.id) { d in
                    MultiSelectRow(
                        label: d.demographic,
                        isSelected: viewModel.selectedDemographics.contains(d.demographic)
                    ) {
                        viewModel.selectedDemographics.toggle(d.demographic)
                    }
                }
            }

            Section {
                Toggle("Coincidencia parcial", isOn: $viewModel.searchContains)
            }

            if let error = viewModel.validationError {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await viewModel.search() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Buscar")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }

            if !viewModel.mangas.isEmpty {
                Section("Resultados") {
                    ForEach(viewModel.mangas, id: \.id) { manga in
                        AdvancedSearchMangaRow(manga: manga)
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
                    }
                }
            }
        }
        .navigationTitle("Búsqueda avanzada")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadCatalog() }
    }
}

// MARK: — Helpers

private struct MultiSelectRow: View {
    let label: String
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack {
                Text(label)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

private struct AdvancedSearchMangaRow: View {
    let manga: MangaDTO

    var body: some View {
        HStack(spacing: 12) {
            AsyncCoverImage(urlString: manga.mainPicture)
                .frame(width: 48, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(manga.titleEnglish ?? manga.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(manga.status.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private extension Set where Element == String {
    mutating func toggle(_ value: String) {
        if contains(value) { remove(value) } else { insert(value) }
    }
}
