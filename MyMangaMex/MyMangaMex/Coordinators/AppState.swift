enum AppState {
    case splash
    case loading
    case listado(Page<MangaDTO>)
    case error(String)
}
