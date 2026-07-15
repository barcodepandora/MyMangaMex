import Testing
import SwiftData
@testable import MyMangaMex

@Suite @MainActor
struct CollectionRepositoryTests {

    private func makeRepository() throws -> CollectionRepository {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: MangaCollectionEntry.self, configurations: config)
        return CollectionRepository(context: ModelContext(container))
    }

    @Test func saveAndRetrieve() throws {
        let repo = try makeRepository()
        try repo.save(mangaId: 42, purchasedVolumes: 10, readingVolume: 5, isComplete: false)
        let entry = try repo.entry(for: 42)
        #expect(entry != nil)
        #expect(entry?.purchasedVolumes == 10)
        #expect(entry?.readingVolume == 5)
        #expect(entry?.isComplete == false)
    }

    @Test func upsertNoDuplicate() throws {
        let repo = try makeRepository()
        try repo.save(mangaId: 42, purchasedVolumes: 5, readingVolume: 2, isComplete: false)
        try repo.save(mangaId: 42, purchasedVolumes: 10, readingVolume: 7, isComplete: true)
        let all = try repo.allEntries()
        #expect(all.count == 1)
        #expect(all.first?.purchasedVolumes == 10)
        #expect(all.first?.readingVolume == 7)
        #expect(all.first?.isComplete == true)
    }

    @Test func readingVolumeCannotExceedPurchased() throws {
        let repo = try makeRepository()
        #expect(throws: CollectionError.readingExceedsPurchased) {
            try repo.save(mangaId: 1, purchasedVolumes: 3, readingVolume: 5, isComplete: false)
        }
    }

    @Test func negativeVolumesForbidden() throws {
        let repo = try makeRepository()
        #expect(throws: CollectionError.negativeVolumes) {
            try repo.save(mangaId: 1, purchasedVolumes: -1, readingVolume: 0, isComplete: false)
        }
    }

    @Test func listAllEntries() throws {
        let repo = try makeRepository()
        try repo.save(mangaId: 1, purchasedVolumes: 2, readingVolume: 1, isComplete: false)
        try repo.save(mangaId: 2, purchasedVolumes: 4, readingVolume: 2, isComplete: false)
        try repo.save(mangaId: 3, purchasedVolumes: 6, readingVolume: 3, isComplete: true)
        let all = try repo.allEntries()
        #expect(all.count == 3)
    }
}
