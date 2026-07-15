import SwiftUI
import SwiftData

struct MangaDetailView: View {
    let manga: MangaDTO
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MangaDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                MangaDetailContentView(viewModel: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(manga.titleEnglish ?? manga.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let repo = CollectionRepository(context: modelContext)
            let vm = MangaDetailViewModel(manga: manga, repository: repo)
            vm.loadCollection()
            viewModel = vm
        }
    }
}

// MARK: — Contenido del detalle

private struct MangaDetailContentView: View {
    @Bindable var viewModel: MangaDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                if !viewModel.authors.isEmpty    { authorsSection }
                if !viewModel.genres.isEmpty     { TagGroupView(title: "Géneros",    tags: viewModel.genres.map(\.genre)) }
                if !viewModel.themes.isEmpty     { TagGroupView(title: "Temáticas",  tags: viewModel.themes.map(\.theme)) }
                if !viewModel.demographics.isEmpty { TagGroupView(title: "Demografía", tags: viewModel.demographics.map(\.demographic)) }
                if let synopsis = viewModel.synopsis { synopsisSection(synopsis) }
                Divider()
                collectionSection
            }
            .padding(.vertical)
        }
    }

    // MARK: Secciones privadas

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncCoverImage(urlString: viewModel.coverURL)
                .frame(width: 100, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.displayTitle)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)

                Text(viewModel.status.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let score = viewModel.score {
                    Label(String(format: "%.2f", score), systemImage: "star.fill")
                        .foregroundStyle(.orange)
                        .font(.subheadline)
                }
                if let vol = viewModel.volumes {
                    Text("\(vol) tomos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    private var authorsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Autores").font(.headline)
            ForEach(viewModel.authors, id: \.id) { author in
                Text("\(author.firstName) \(author.lastName) — \(author.role)")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }

    private func synopsisSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sinopsis").font(.headline)
            Text(text).font(.body)
        }
        .padding(.horizontal)
    }

    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mi colección").font(.headline)

            Stepper(
                "Tomos comprados: \(viewModel.purchasedVolumes)",
                value: $viewModel.purchasedVolumes,
                in: 0...9999
            )
            Stepper(
                "Tomo de lectura: \(viewModel.readingVolume)",
                value: $viewModel.readingVolume,
                in: 0...9999
            )
            Toggle("Colección completa", isOn: $viewModel.isComplete)

            if let err = viewModel.validationError {
                Text(errorMessage(for: err))
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Guardar colección") {
                viewModel.saveCollection()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    private func errorMessage(for error: CollectionError) -> String {
        switch error {
        case .negativeVolumes:
            return "El número de tomos no puede ser negativo."
        case .readingExceedsPurchased:
            return "El tomo de lectura no puede superar los tomos comprados."
        }
    }
}

// MARK: — Grupo de etiquetas reutilizable

private struct TagGroupView: View {
    let title: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
