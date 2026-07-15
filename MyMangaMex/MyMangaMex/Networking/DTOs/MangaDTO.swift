import Foundation

struct MangaDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let titleJapanese: String?
    let titleEnglish: String?
    let chapters: Int?
    let volumes: Int?
    let status: String
    let startDate: Date?
    let endDate: Date?
    let score: Double?
    let sypnosis: String?
    let background: String?
    let mainPicture: String?
    let url: String?
    let authors: [AuthorDTO]
    let genres: [GenreDTO]
    let themes: [ThemeDTO]
    let demographics: [DemographicDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, titleJapanese, titleEnglish, chapters, volumes
        case status, startDate, endDate, score, sypnosis, background
        case mainPicture, url, authors, genres, themes, demographics
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(Int.self,    forKey: .id)
        title        = try c.decode(String.self, forKey: .title)
        titleJapanese  = try c.decodeIfPresent(String.self,       forKey: .titleJapanese)
        titleEnglish   = try c.decodeIfPresent(String.self,       forKey: .titleEnglish)
        chapters       = try c.decodeIfPresent(Int.self,          forKey: .chapters)
        volumes        = try c.decodeIfPresent(Int.self,          forKey: .volumes)
        status         = try c.decode(String.self,                forKey: .status)
        startDate      = try c.decodeIfPresent(Date.self,         forKey: .startDate)
        endDate        = try c.decodeIfPresent(Date.self,         forKey: .endDate)
        score          = try c.decodeIfPresent(Double.self,       forKey: .score)
        sypnosis       = try c.decodeIfPresent(String.self,       forKey: .sypnosis)
        background     = try c.decodeIfPresent(String.self,       forKey: .background)
        authors        = try c.decodeIfPresent([AuthorDTO].self,       forKey: .authors)      ?? []
        genres         = try c.decodeIfPresent([GenreDTO].self,        forKey: .genres)       ?? []
        themes         = try c.decodeIfPresent([ThemeDTO].self,        forKey: .themes)       ?? []
        demographics   = try c.decodeIfPresent([DemographicDTO].self,  forKey: .demographics) ?? []

        // The API embeds literal quote characters inside mainPicture and url values.
        let rawPic = try c.decodeIfPresent(String.self, forKey: .mainPicture)
        mainPicture = rawPic?.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let rawURL = try c.decodeIfPresent(String.self, forKey: .url)
        url = rawURL?.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
