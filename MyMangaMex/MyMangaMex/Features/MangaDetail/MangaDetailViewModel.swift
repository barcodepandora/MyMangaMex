import Foundation
import Observation

@Observable @MainActor
final class MangaDetailViewModel {
    let manga: MangaDTO

    var purchasedVolumes: Int = 0
    var readingVolume: Int = 0
    var isComplete: Bool = false

    private(set) var validationError: CollectionError?

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
        purchasedVolumes = entry.purchasedVolumes
        readingVolume = entry.readingVolume
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
        } catch {
            // propagación inesperada del repositorio
        }
    }
}
