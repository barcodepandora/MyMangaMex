import Testing
@testable import MyMangaMex
import Foundation

@Suite("APIRouter — Construcción de URLRequest")
@MainActor
struct APIRouterTests {

    let base = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com")!

    // MARK: — Tarea 1.1: Rutas y métodos

    @Test("listMangas — ruta y método")
    func listMangasRouting() throws {
        let req = try APIRouter.listMangas(page: 1, per: 10).urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/mangas")
        #expect(req.httpMethod == "GET")
    }

    @Test("listBestMangas — ruta y método")
    func listBestMangasRouting() throws {
        let req = try APIRouter.listBestMangas(page: 1, per: 10).urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/bestMangas")
        #expect(req.httpMethod == "GET")
    }

    @Test("listAuthors — ruta")
    func listAuthorsRouting() throws {
        let req = try APIRouter.listAuthors.urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/authors")
        #expect(req.httpMethod == "GET")
    }

    @Test("listDemographics — ruta")
    func listDemographicsRouting() throws {
        let req = try APIRouter.listDemographics.urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/demographics")
    }

    @Test("listGenres — ruta")
    func listGenresRouting() throws {
        let req = try APIRouter.listGenres.urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/genres")
    }

    @Test("listThemes — ruta")
    func listThemesRouting() throws {
        let req = try APIRouter.listThemes.urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/themes")
    }

    @Test("listMangasByGenre — ruta incluye valor")
    func listMangasByGenreRouting() throws {
        let req = try APIRouter.listMangasByGenre("romance").urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/mangaByGenre/romance")
    }

    @Test("listMangasByDemographic — ruta incluye valor")
    func listMangasByDemographicRouting() throws {
        let req = try APIRouter.listMangasByDemographic("shoujo").urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/mangaByDemographic/shoujo")
    }

    @Test("listMangasByTheme — ruta incluye valor")
    func listMangasByThemeRouting() throws {
        let req = try APIRouter.listMangasByTheme("school").urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/mangaByTheme/school")
    }

    @Test("listMangasByAuthor — ruta incluye ID")
    func listMangasByAuthorRouting() throws {
        let authorID = "998C1B16-E3DB-47D1-8157-8389B5345D03"
        let req = try APIRouter.listMangasByAuthor(authorID).urlRequest(baseURL: base)
        #expect(req.url?.path == "/list/mangaByAuthor/\(authorID)")
    }

    @Test("searchMangasBeginsWith — ruta incluye texto")
    func searchMangasBeginsWithRouting() throws {
        let req = try APIRouter.searchMangasBeginsWith("dragon", page: 1, per: 20).urlRequest(baseURL: base)
        #expect(req.url?.path == "/search/mangasBeginsWith/dragon")
    }

    @Test("searchMangasContains — ruta incluye texto")
    func searchMangasContainsRouting() throws {
        let req = try APIRouter.searchMangasContains("ball", page: 1, per: 20).urlRequest(baseURL: base)
        #expect(req.url?.path == "/search/mangasContains/ball")
    }

    @Test("searchAuthor — ruta incluye texto")
    func searchAuthorRouting() throws {
        let req = try APIRouter.searchAuthor("toriya").urlRequest(baseURL: base)
        #expect(req.url?.path == "/search/author/toriya")
    }

    @Test("searchManga por ID — ruta incluye ID")
    func searchMangaByIDRouting() throws {
        let req = try APIRouter.searchManga(42).urlRequest(baseURL: base)
        #expect(req.url?.path == "/search/manga/42")
    }

    @Test("searchMangaAdvanced — método POST y ruta correcta")
    func searchMangaAdvancedRouting() throws {
        let search = CustomSearch(searchContains: false)
        let req = try APIRouter.searchMangaAdvanced(search, page: 1, per: 20).urlRequest(baseURL: base)
        #expect(req.url?.path == "/search/manga")
        #expect(req.httpMethod == "POST")
    }

    // MARK: — Tarea 1.2: Coherencia de paginación

    @Test("listMangas — per se conserva entre páginas")
    func paginationCoherence() throws {
        let req1 = try APIRouter.listMangas(page: 1, per: 20).urlRequest(baseURL: base)
        let req2 = try APIRouter.listMangas(page: 2, per: 20).urlRequest(baseURL: base)

        let items1 = URLComponents(url: req1.url!, resolvingAgainstBaseURL: false)?.queryItems
        let items2 = URLComponents(url: req2.url!, resolvingAgainstBaseURL: false)?.queryItems

        let per1 = items1?.first(where: { $0.name == "per" })?.value
        let per2 = items2?.first(where: { $0.name == "per" })?.value

        #expect(per1 == "20")
        #expect(per1 == per2)
    }

    @Test("listMangas — query items contienen page y per correctos")
    func listMangasQueryItems() throws {
        let req = try APIRouter.listMangas(page: 3, per: 50).urlRequest(baseURL: base)
        let items = URLComponents(url: req.url!, resolvingAgainstBaseURL: false)?.queryItems
        #expect(items?.first(where: { $0.name == "page" })?.value == "3")
        #expect(items?.first(where: { $0.name == "per" })?.value == "50")
    }
}
