import Foundation

struct AuthorDTO: Decodable, Sendable {
    let id: UUID
    let firstName: String
    let lastName: String
    let role: String

    enum CodingKeys: String, CodingKey { case id, firstName, lastName, role }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(UUID.self,   forKey: .id)
        firstName = try c.decode(String.self, forKey: .firstName)
        lastName  = try c.decode(String.self, forKey: .lastName)
        role      = try c.decode(String.self, forKey: .role)
    }
}
