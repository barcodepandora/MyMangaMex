import Foundation

struct DemographicDTO: Decodable, Sendable {
    let id: UUID
    let demographic: String

    enum CodingKeys: String, CodingKey { case id, demographic }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(UUID.self,   forKey: .id)
        demographic = try c.decode(String.self, forKey: .demographic)
    }
}
