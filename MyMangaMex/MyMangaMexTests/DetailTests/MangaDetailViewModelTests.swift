import Testing
import SwiftData
@testable import MyMangaMex
import Foundation

// MARK: — Helpers

private func makeMangaDTO(id: Int = 42, title: String = "Test Manga") -> MangaDTO {
    let json = "{\"id\":\(id),\"title\":\"\(title)\",\"status\":\"Publishing\",\"authors\":[],\"genres\":[],\"themes\":[],\"demographics\":[]}"
    return try! JSONDecoder().decode(MangaDTO.self, from: Data(json.utf8))
}

private func makeDragonBallDTO() -> MangaDTO {
    let json = #"""
    {
        "id": 42, "title": "Dragon Ball", "titleEnglish": "Dragon Ball", "status": "finished",
        "authors": [{"id": "998C1B16-E3DB-47D1-8157-8389B5345D03", "firstName": "Akira", "lastName": "Toriyama", "role": "Story & Art"}],
        "genres": [{"id": "72C8E862-334F-4F00-B8EC-E1E4125BB7CD", "genre": "Action"}],
        "themes": [{"id": "ADC7CBC8-36B9-4E52-924A-4272B7B2CB2C", "theme": "Martial Arts"}],
        "demographics": [{"id": "5E05BBF1-A72E-4231-9487-71CFE508F9F9", "demographic": "Shounen"}]
    }
    """#
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try! decoder.decode(MangaDTO.self, from: Data(json.utf8))
}

// MARK: — Mock de repositorio con validación real

private final class MockCollectionRepository: CollectionRepositoryProtocol, @unchecked Sendable {
    var entries: [Int: MangaCollectionEntry] = [:]
    var lastSavedArgs: (mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool)?

    func save(mangaId: Int, purchasedVolumes: Int, readingVolume: Int, isComplete: Bool) throws {
        guard purchasedVolumes >= 0 else { throw CollectionError.negativeVolumes }
        guard readingVolume <= purchasedVolumes else { throw CollectionError.readingExceedsPurchased }
        entries[mangaId] = MangaCollectionEntry(
            mangaId: mangaId,
            purchasedVolumes: purchasedVolumes,
            readingVolume: readingVolume,
            isComplete: isComplete
        )
        lastSavedArgs = (mangaId, purchasedVolumes, readingVolume, isComplete)
    }

    func entry(for mangaId: Int) throws -> MangaCollectionEntry? {
        entries[mangaId]
    }

    func allEntries() throws -> [MangaCollectionEntry] {
        Array(entries.values)
    }
}

// MARK: — Tests

@Suite("MangaDetailViewModel — Ficha y colección")
@MainActor
struct MangaDetailViewModelTests {

    // MARK: Tarea 5.2 — Carga y presentación de la ficha

    @Test("displayTitle prefiere titleEnglish si está disponible")
    func displayTitlePrefersEnglish() {
        let json = #"{"id":1,"title":"ドラゴンボール","titleEnglish":"Dragon Ball","status":"finished","authors":[],"genres":[],"themes":[],"demographics":[]}"#
        let manga = try! JSONDecoder().decode(MangaDTO.self, from: Data(json.utf8))
        let vm = MangaDetailViewModel(manga: manga, repository: MockCollectionRepository())
        #expect(vm.displayTitle == "Dragon Ball")
    }

    @Test("displayTitle cae a title cuando titleEnglish es nil")
    func displayTitleFallsBackToTitle() {
        let json = #"{"id":1,"title":"ドラゴンボール","status":"finished","authors":[],"genres":[],"themes":[],"demographics":[]}"#
        let manga = try! JSONDecoder().decode(MangaDTO.self, from: Data(json.utf8))
        let vm = MangaDetailViewModel(manga: manga, repository: MockCollectionRepository())
        #expect(vm.displayTitle == "ドラゴンボール")
    }

    @Test("ViewModel expone autores, géneros, temáticas y demografías del DTO")
    func viewModelExposesAllRelations() {
        let manga = makeDragonBallDTO()
        let vm = MangaDetailViewModel(manga: manga, repository: MockCollectionRepository())
        #expect(vm.authors.count == 1)
        #expect(vm.authors.first?.firstName == "Akira")
        #expect(vm.genres.count == 1)
        #expect(vm.genres.first?.genre == "Action")
        #expect(vm.themes.count == 1)
        #expect(vm.demographics.count == 1)
        #expect(vm.demographics.first?.demographic == "Shounen")
    }

    // MARK: Tarea 5.3 — Carga de colección existente

    @Test("loadCollection carga datos existentes del repositorio")
    func loadCollectionFromRepository() {
        let repo = MockCollectionRepository()
        repo.entries[42] = MangaCollectionEntry(
            mangaId: 42, purchasedVolumes: 5, readingVolume: 3, isComplete: false
        )
        let vm = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm.loadCollection()
        #expect(vm.purchasedVolumes == 5)
        #expect(vm.readingVolume == 3)
        #expect(vm.isComplete == false)
    }

    @Test("loadCollection deja valores en cero cuando no hay entrada previa")
    func loadCollectionWithNoEntryLeavesDefaults() {
        let vm = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: MockCollectionRepository())
        vm.loadCollection()
        #expect(vm.purchasedVolumes == 0)
        #expect(vm.readingVolume == 0)
        #expect(vm.isComplete == false)
    }

    // MARK: Tarea 5.4 — Guardar datos de colección

    @Test("saveCollection llama al repositorio con los valores editados")
    func saveCollectionCallsRepository() {
        let repo = MockCollectionRepository()
        let vm = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm.purchasedVolumes = 10
        vm.readingVolume = 5
        vm.isComplete = true
        vm.saveCollection()
        #expect(repo.lastSavedArgs?.mangaId == 42)
        #expect(repo.lastSavedArgs?.purchasedVolumes == 10)
        #expect(repo.lastSavedArgs?.readingVolume == 5)
        #expect(repo.lastSavedArgs?.isComplete == true)
    }

    @Test("saveCollection exitoso limpia el validationError previo")
    func saveCollectionClearsError() {
        let repo = MockCollectionRepository()
        let vm = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm.purchasedVolumes = 2
        vm.readingVolume = 5   // inválido → genera error
        vm.saveCollection()
        guard vm.validationError != nil else {
            Issue.record("Prerrequisito: se esperaba un validationError antes de corregir")
            return
        }
        vm.readingVolume = 1   // válido
        vm.saveCollection()
        #expect(vm.validationError == nil)
    }

    // MARK: Tarea 5.5 — Rechazo legible de valores inválidos

    @Test("lectura mayor que comprados produce validationError legible")
    func readingExceedsPurchasedSetsError() {
        let vm = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: MockCollectionRepository())
        vm.purchasedVolumes = 3
        vm.readingVolume = 5
        vm.saveCollection()
        #expect(vm.validationError == .readingExceedsPurchased)
    }

    @Test("tomos comprados negativos producen validationError legible")
    func negativeVolumesSetsError() {
        let vm = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: MockCollectionRepository())
        vm.purchasedVolumes = -1
        vm.readingVolume = 0
        vm.saveCollection()
        #expect(vm.validationError == .negativeVolumes)
    }

    // MARK: Tarea 5.6 — Persistencia al volver a entrar

    @Test("nueva instancia del ViewModel carga los datos guardados (mock compartido)")
    func newInstanceLoadsPersistedDataMock() {
        let repo = MockCollectionRepository()
        let vm1 = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm1.purchasedVolumes = 7
        vm1.readingVolume = 4
        vm1.isComplete = false
        vm1.saveCollection()

        let vm2 = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm2.loadCollection()
        #expect(vm2.purchasedVolumes == 7)
        #expect(vm2.readingVolume == 4)
        #expect(vm2.isComplete == false)
    }

    @Test("nueva instancia del ViewModel carga datos del repositorio real en memoria")
    func newInstanceLoadsPersistedDataReal() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: MangaCollectionEntry.self, configurations: config)
        let context = ModelContext(container)
        let repo = CollectionRepository(context: context)

        let vm1 = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm1.purchasedVolumes = 7
        vm1.readingVolume = 4
        vm1.isComplete = false
        vm1.saveCollection()

        let vm2 = MangaDetailViewModel(manga: makeMangaDTO(id: 42), repository: repo)
        vm2.loadCollection()
        #expect(vm2.purchasedVolumes == 7)
        #expect(vm2.readingVolume == 4)
        #expect(vm2.isComplete == false)
    }
}
