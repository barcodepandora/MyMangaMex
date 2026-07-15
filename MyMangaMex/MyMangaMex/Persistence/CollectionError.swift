enum CollectionError: Error, Sendable, Equatable {
    case negativeVolumes
    case readingExceedsPurchased
}
