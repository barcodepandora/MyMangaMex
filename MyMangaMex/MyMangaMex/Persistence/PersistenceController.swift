import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MyMangaMex", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData load failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Modelo CoreData definido en código — evita depender de un .xcdatamodeld en el bundle
    nonisolated(unsafe) static let model: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "MangaCollectionEntry"
        entity.managedObjectClassName = "MangaCollectionEntry"

        func attr(_ name: String, type: NSAttributeType, default val: Any) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.defaultValue = val
            return a
        }

        entity.properties = [
            attr("mangaId",           type: .integer32AttributeType, default: Int32(0)),
            attr("purchasedVolumes",   type: .integer32AttributeType, default: Int32(0)),
            attr("readingVolume",      type: .integer32AttributeType, default: Int32(0)),
            attr("isComplete",         type: .booleanAttributeType,   default: false),
        ]

        model.entities = [entity]
        return model
    }()
}
