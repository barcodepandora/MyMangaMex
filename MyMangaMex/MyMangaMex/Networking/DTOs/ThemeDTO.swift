import Foundation

struct ThemeDTO: Decodable, Sendable {
    let id: UUID
    let theme: String

    enum CodingKeys: String, CodingKey { case id, theme }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id    = try c.decode(UUID.self,   forKey: .id)
        theme = try c.decode(String.self, forKey: .theme)
    }
}
