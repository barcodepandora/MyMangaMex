import CoreData

protocol CollectionRepositoryProtocol {
    func save(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) throws
    func entry(for mangaId: Int) throws -> MangaCollectionEntry?
    func allEntries() throws -> [MangaCollectionEntry]
}

final class CollectionRepository: CollectionRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func save(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) throws {
        guard purchasedVolumes >= 0 else { throw CollectionError.negativeVolumes }
        guard readingVolume <= purchasedVolumes else { throw CollectionError.readingExceedsPurchased }

        let entry = (try self.entry(for: mangaId)) ?? MangaCollectionEntry(context: context)
        entry.mangaId = Int32(mangaId)
        entry.purchasedVolumes = Int32(purchasedVolumes)
        entry.readingVolume = Int32(readingVolume)
        entry.isComplete = isComplete
        try context.save()
    }

    func entry(for mangaId: Int) throws -> MangaCollectionEntry? {
        let request = NSFetchRequest<MangaCollectionEntry>(entityName: "MangaCollectionEntry")
        request.predicate = NSPredicate(format: "mangaId == %d", Int32(mangaId))
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func allEntries() throws -> [MangaCollectionEntry] {
        try context.fetch(NSFetchRequest<MangaCollectionEntry>(entityName: "MangaCollectionEntry"))
    }
}
