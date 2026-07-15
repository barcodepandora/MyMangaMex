import Foundation

struct GenreDTO: Decodable, Sendable {
    let id: UUID
    let genre: String

    enum CodingKeys: String, CodingKey { case id, genre }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id    = try c.decode(UUID.self,   forKey: .id)
        genre = try c.decode(String.self, forKey: .genre)
    }
}
