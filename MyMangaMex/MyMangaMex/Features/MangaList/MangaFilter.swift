enum MangaFilter: Equatable, Sendable {
    case none
    case byGenre(String)
    case byDemographic(String)
    case byTheme(String)
}
