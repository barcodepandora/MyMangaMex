import Testing
@testable import MyMangaMex
import Foundation

@Suite("CustomSearch — Codificación POST")
@MainActor
struct CustomSearchTests {

    // MARK: — Tarea 1.6

    @Test("Campos nil no aparecen en el JSON codificado")
    func nilFieldsOmitted() throws {
        let search = CustomSearch(searchContains: false)
        let data = try JSONEncoder().encode(search)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["searchTitle"] == nil)
        #expect(json["searchAuthorFirstName"] == nil)
        #expect(json["searchAuthorLastName"] == nil)
        #expect(json["searchGenres"] == nil)
        #expect(json["searchThemes"] == nil)
        #expect(json["searchDemographics"] == nil)
        #expect(json["searchContains"] as? Bool == false)
    }

    @Test("APIRouter arma body POST con searchTitle y searchContains")
    func advancedSearchRequestBody() throws {
        let search = CustomSearch(searchTitle: "Dragon", searchContains: true)
        let base   = URL(string: "https://mymanga-acacademy-5607149ebe3d.herokuapp.com")!
        let req    = try APIRouter.searchMangaAdvanced(search, page: 1, per: 20).urlRequest(baseURL: base)

        #expect(req.httpMethod == "POST")
        #expect(req.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let body = try JSONSerialization.jsonObject(with: req.httpBody!) as! [String: Any]
        #expect(body["searchTitle"] as? String == "Dragon")
        #expect(body["searchContains"] as? Bool == true)
        #expect(body["searchAuthorFirstName"] == nil)
    }

    @Test("CustomSearch con colecciones las serializa correctamente")
    func searchWithCollections() throws {
        let search = CustomSearch(
            searchGenres: ["Action", "Romance"],
            searchThemes: ["School"],
            searchContains: true
        )
        let data   = try JSONEncoder().encode(search)
        let json   = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let genres = json["searchGenres"] as? [String]
        #expect(genres?.count == 2)
        #expect(genres?.contains("Action") == true)

        let themes = json["searchThemes"] as? [String]
        #expect(themes?.count == 1)
    }
}
