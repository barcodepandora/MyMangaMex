import Testing
@testable import MyMangaMex
import Foundation

@Suite("DTOs — Decodificación")
@MainActor
struct DTOTests {

    // JSON de Dragon Ball del enunciado — mainPicture y url llevan comillas anidadas reales.
    let dragonBallJSON = """
    {
        "titleJapanese": "ドラゴンボール",
        "authors": [
            {
                "id": "998C1B16-E3DB-47D1-8157-8389B5345D03",
                "firstName": "Akira",
                "lastName": "Toriyama",
                "role": "Story & Art"
            }
        ],
        "themes": [
            {
                "id": "ADC7CBC8-36B9-4E52-924A-4272B7B2CB2C",
                "theme": "Martial Arts"
            },
            {
                "id": "472FB2AE-13C0-4EEE-9A45-A7B75AC5DC29",
                "theme": "Super Power"
            }
        ],
        "title": "Dragon Ball",
        "id": 42,
        "endDate": "1995-05-23T00:00:00Z",
        "score": 8.41,
        "status": "finished",
        "demographics": [
            {
                "demographic": "Shounen",
                "id": "5E05BBF1-A72E-4231-9487-71CFE508F9F9"
            }
        ],
        "genres": [
            {"genre": "Action",    "id": "72C8E862-334F-4F00-B8EC-E1E4125BB7CD"},
            {"genre": "Adventure", "id": "BE70E289-D414-46A9-8F15-928EAFBC5A32"},
            {"genre": "Comedy",    "id": "F974BCB6-B002-44A6-A224-90D1E50595A2"},
            {"genre": "Sci-Fi",    "id": "2DEDC015-82DA-4EF4-B983-F0F58C8F689E"}
        ],
        "startDate": "1984-11-20T00:00:00Z",
        "titleEnglish": "Dragon Ball",
        "chapters": 520,
        "mainPicture": "\\"https://cdn.myanimelist.net/images/manga/1/267793l.jpg\\"",
        "sypnosis": "Bulma, a headstrong 16-year-old girl, is on a quest.",
        "background": "Dragon Ball has become one of the most successful manga series.",
        "url": "\\"https://myanimelist.net/manga/42/Dragon_Ball\\"",
        "volumes": 42
    }
    """

    private func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: — Tarea 1.3

    @Test("MangaDTO — campos básicos de Dragon Ball")
    func decodeMangaDTOBasics() throws {
        let dto = try makeDecoder().decode(MangaDTO.self, from: dragonBallJSON.data(using: .utf8)!)
        #expect(dto.id == 42)
        #expect(dto.title == "Dragon Ball")
        #expect(dto.titleEnglish == "Dragon Ball")
        #expect(dto.titleJapanese == "ドラゴンボール")
        #expect(dto.chapters == 520)
        #expect(dto.volumes == 42)
        #expect(dto.status == "finished")
        #expect(dto.score == 8.41)
    }

    @Test("MangaDTO — autores, géneros, temas y demografías")
    func decodeMangaDTORelations() throws {
        let dto = try makeDecoder().decode(MangaDTO.self, from: dragonBallJSON.data(using: .utf8)!)
        #expect(dto.authors.count == 1)
        #expect(dto.authors.first?.firstName == "Akira")
        #expect(dto.authors.first?.lastName == "Toriyama")
        #expect(dto.themes.count == 2)
        #expect(dto.genres.count == 4)
        #expect(dto.demographics.count == 1)
        #expect(dto.demographics.first?.demographic == "Shounen")
    }

    @Test("MangaDTO — limpia comillas anidadas en mainPicture y url")
    func decodeMangaDTOCleanURLs() throws {
        let dto = try makeDecoder().decode(MangaDTO.self, from: dragonBallJSON.data(using: .utf8)!)
        #expect(dto.mainPicture == "https://cdn.myanimelist.net/images/manga/1/267793l.jpg")
        #expect(dto.url == "https://myanimelist.net/manga/42/Dragon_Ball")
    }

    @Test("MangaDTO — fechas ISO8601 no son nil")
    func decodeMangaDTODates() throws {
        let dto = try makeDecoder().decode(MangaDTO.self, from: dragonBallJSON.data(using: .utf8)!)
        #expect(dto.startDate != nil)
        #expect(dto.endDate != nil)
    }

    // MARK: — Tarea 1.4

    @Test("Page<MangaDTO> — metadata de paginación correcta")
    func decodePageMetadata() throws {
        let json = """
        {
            "items": [],
            "metadata": {"total": 64833, "page": 1, "per": 10}
        }
        """
        let page = try JSONDecoder().decode(Page<MangaDTO>.self, from: json.data(using: .utf8)!)
        #expect(page.metadata.total == 64833)
        #expect(page.metadata.page == 1)
        #expect(page.metadata.per == 10)
        #expect(page.items.isEmpty)
    }

    @Test("Page<MangaDTO> — expone items junto a metadata")
    func decodePageWithItems() throws {
        let json = """
        {
            "items": [{
                "id": 42, "title": "Dragon Ball",
                "titleJapanese": "ドラゴンボール", "titleEnglish": "Dragon Ball",
                "status": "finished",
                "authors": [], "genres": [], "themes": [], "demographics": []
            }],
            "metadata": {"total": 1, "page": 1, "per": 10}
        }
        """
        let page = try makeDecoder().decode(Page<MangaDTO>.self, from: json.data(using: .utf8)!)
        #expect(page.items.count == 1)
        #expect(page.items.first?.title == "Dragon Ball")
    }
}
