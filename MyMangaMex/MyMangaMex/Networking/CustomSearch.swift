import Foundation

struct CustomSearch: Codable, Sendable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool

    nonisolated init(
        searchTitle: String? = nil,
        searchAuthorFirstName: String? = nil,
        searchAuthorLastName: String? = nil,
        searchGenres: [String]? = nil,
        searchThemes: [String]? = nil,
        searchDemographics: [String]? = nil,
        searchContains: Bool
    ) {
        self.searchTitle           = searchTitle
        self.searchAuthorFirstName = searchAuthorFirstName
        self.searchAuthorLastName  = searchAuthorLastName
        self.searchGenres          = searchGenres
        self.searchThemes          = searchThemes
        self.searchDemographics    = searchDemographics
        self.searchContains        = searchContains
    }

    enum CodingKeys: String, CodingKey {
        case searchTitle, searchAuthorFirstName, searchAuthorLastName
        case searchGenres, searchThemes, searchDemographics, searchContains
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(searchTitle,           forKey: .searchTitle)
        try c.encodeIfPresent(searchAuthorFirstName, forKey: .searchAuthorFirstName)
        try c.encodeIfPresent(searchAuthorLastName,  forKey: .searchAuthorLastName)
        try c.encodeIfPresent(searchGenres,          forKey: .searchGenres)
        try c.encodeIfPresent(searchThemes,          forKey: .searchThemes)
        try c.encodeIfPresent(searchDemographics,    forKey: .searchDemographics)
        try c.encode(searchContains,                 forKey: .searchContains)
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c               = try decoder.container(keyedBy: CodingKeys.self)
        searchTitle           = try c.decodeIfPresent(String.self,   forKey: .searchTitle)
        searchAuthorFirstName = try c.decodeIfPresent(String.self,   forKey: .searchAuthorFirstName)
        searchAuthorLastName  = try c.decodeIfPresent(String.self,   forKey: .searchAuthorLastName)
        searchGenres          = try c.decodeIfPresent([String].self,  forKey: .searchGenres)
        searchThemes          = try c.decodeIfPresent([String].self,  forKey: .searchThemes)
        searchDemographics    = try c.decodeIfPresent([String].self,  forKey: .searchDemographics)
        searchContains        = try c.decode(Bool.self,               forKey: .searchContains)
    }
}
