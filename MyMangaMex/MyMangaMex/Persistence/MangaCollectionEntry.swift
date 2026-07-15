import SwiftData

@Model
final class MangaCollectionEntry {
    var mangaId: Int
    var purchasedVolumes: Int
    var readingVolume: Int
    var isComplete: Bool

    init(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) {
        self.mangaId = mangaId
        self.purchasedVolumes = purchasedVolumes
        self.readingVolume = readingVolume
        self.isComplete = isComplete
    }
}
