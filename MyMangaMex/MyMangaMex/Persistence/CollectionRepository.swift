import SwiftData

protocol CollectionRepositoryProtocol {
    func save(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) throws
    func entry(for mangaId: Int) throws -> MangaCollectionEntry?
    func allEntries() throws -> [MangaCollectionEntry]
}

final class CollectionRepository: CollectionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) throws {
        guard purchasedVolumes >= 0 else { throw CollectionError.negativeVolumes }
        guard readingVolume <= purchasedVolumes else { throw CollectionError.readingExceedsPurchased }

        if let existing = try entry(for: mangaId) {
            existing.purchasedVolumes = purchasedVolumes
            existing.readingVolume = readingVolume
            existing.isComplete = isComplete
        } else {
            context.insert(MangaCollectionEntry(
                mangaId: mangaId,
                purchasedVolumes: purchasedVolumes,
                readingVolume: readingVolume,
                isComplete: isComplete
            ))
        }
    }

    func entry(for mangaId: Int) throws -> MangaCollectionEntry? {
        try context.fetch(FetchDescriptor<MangaCollectionEntry>()).first { $0.mangaId == mangaId }
    }

    func allEntries() throws -> [MangaCollectionEntry] {
        try context.fetch(FetchDescriptor<MangaCollectionEntry>())
    }
}
