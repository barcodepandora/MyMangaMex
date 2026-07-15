import Foundation

enum APIRouter: Sendable {
    case listMangas(page: Int, per: Int)
    case listBestMangas(page: Int, per: Int)
    case listAuthors
    case listDemographics
    case listGenres
    case listThemes
    case listMangasByGenre(String)
    case listMangasByDemographic(String)
    case listMangasByTheme(String)
    case listMangasByAuthor(String)
    case searchMangasBeginsWith(String)
    case searchMangasContains(String)
    case searchAuthor(String)
    case searchManga(Int)
    case searchMangaAdvanced(CustomSearch)

    nonisolated func urlRequest(baseURL: URL) throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        let qi = queryItems
        if !qi.isEmpty { components.queryItems = qi }

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod

        if let body = httpBody {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}

// MARK: — Private request components

private extension APIRouter {
    nonisolated var path: String {
        switch self {
        case .listMangas:                     return "/list/mangas"
        case .listBestMangas:                 return "/list/bestMangas"
        case .listAuthors:                    return "/list/authors"
        case .listDemographics:               return "/list/demographics"
        case .listGenres:                     return "/list/genres"
        case .listThemes:                     return "/list/themes"
        case .listMangasByGenre(let v):       return "/list/mangaByGenre/\(v)"
        case .listMangasByDemographic(let v): return "/list/mangaByDemographic/\(v)"
        case .listMangasByTheme(let v):       return "/list/mangaByTheme/\(v)"
        case .listMangasByAuthor(let id):     return "/list/mangaByAuthor/\(id)"
        case .searchMangasBeginsWith(let t):  return "/search/mangasBeginsWith/\(t)"
        case .searchMangasContains(let t):    return "/search/mangasContains/\(t)"
        case .searchAuthor(let t):            return "/search/author/\(t)"
        case .searchManga(let id):            return "/search/manga/\(id)"
        case .searchMangaAdvanced:            return "/search/manga"
        }
    }

    nonisolated var httpMethod: String {
        switch self {
        case .searchMangaAdvanced: return "POST"
        default:                   return "GET"
        }
    }

    nonisolated var queryItems: [URLQueryItem] {
        switch self {
        case .listMangas(let page, let per),
             .listBestMangas(let page, let per):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per",  value: "\(per)")
            ]
        default:
            return []
        }
    }

    nonisolated var httpBody: Data? {
        switch self {
        case .searchMangaAdvanced(let search):
            return try? JSONEncoder().encode(search)
        default:
            return nil
        }
    }
}
