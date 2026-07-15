import Foundation

struct PageMetadata: Decodable, Sendable {
    let total: Int
    let page: Int
    let per: Int

    enum CodingKeys: String, CodingKey { case total, page, per }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        total = try c.decode(Int.self, forKey: .total)
        page  = try c.decode(Int.self, forKey: .page)
        per   = try c.decode(Int.self, forKey: .per)
    }
}

struct Page<T: Decodable & Sendable>: Decodable, Sendable {
    let items: [T]
    let metadata: PageMetadata

    enum CodingKeys: String, CodingKey { case items, metadata }

    nonisolated init(from decoder: any Decoder) throws {
        let c    = try decoder.container(keyedBy: CodingKeys.self)
        items    = try c.decode([T].self,           forKey: .items)
        metadata = try c.decode(PageMetadata.self,  forKey: .metadata)
    }
}
