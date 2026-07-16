import CoreData

@objc(MangaCollectionEntry)
final class MangaCollectionEntry: NSManagedObject {
    @NSManaged var mangaId: Int32
    @NSManaged var purchasedVolumes: Int32
    @NSManaged var readingVolume: Int32
    @NSManaged var isComplete: Bool

    // Inicializador de conveniencia para mocks y tests (no inserta en ningún contexto)
    convenience init(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) {
        let entity = PersistenceController.model.entitiesByName["MangaCollectionEntry"]!
        self.init(entity: entity, insertInto: nil)
        self.mangaId = Int32(mangaId)
        self.purchasedVolumes = Int32(purchasedVolumes)
        self.readingVolume = Int32(readingVolume)
        self.isComplete = isComplete
    }
}
