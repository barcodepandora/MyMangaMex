import Foundation
import Combine

@MainActor
final class MangaDetailViewModel: ObservableObject {
    let manga: MangaDTO

    @Published var purchasedVolumes: Int = 0
    @Published var readingVolume: Int = 0
    @Published var isComplete: Bool = false

    @Published private(set) var validationError: CollectionError?

    private let repository: any CollectionRepositoryProtocol

    var displayTitle: String { manga.titleEnglish ?? manga.title }
    var authors: [AuthorDTO] { manga.authors }
    var genres: [GenreDTO] { manga.genres }
    var themes: [ThemeDTO] { manga.themes }
    var demographics: [DemographicDTO] { manga.demographics }
    var synopsis: String? { manga.sypnosis }
    var score: Double? { manga.score }
    var volumes: Int? { manga.volumes }
    var status: String { manga.status }
    var coverURL: String? { manga.mainPicture }

    init(manga: MangaDTO, repository: any CollectionRepositoryProtocol) {
        self.manga = manga
        self.repository = repository
    }

    func loadCollection() {
        guard let entry = try? repository.entry(for: manga.id) else { return }
        purchasedVolumes = Int(entry.purchasedVolumes)
        readingVolume = Int(entry.readingVolume)
        isComplete = entry.isComplete
    }

    func saveCollection() {
        do {
            try repository.save(
                mangaId: manga.id,
                purchasedVolumes: purchasedVolumes,
                readingVolume: readingVolume,
                isComplete: isComplete
            )
            validationError = nil
        } catch let error as CollectionError {
            validationError = error
        } catch {}
    }
}
