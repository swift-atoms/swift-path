#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension Path.Stem {

        public enum Error: Swift::Error, Sendable, Equatable {

            case empty

            case containsPathSeparator

            case containsControlCharacters
        }
    }

    extension Path.Stem.Error: CustomStringConvertible {
        public var description: Swift::String {
            switch self {
            case .empty:
                return "Stem is empty"

            case .containsPathSeparator:
                return "Stem contains path separator"

            case .containsControlCharacters:
                return "Stem contains control characters"
            }
        }
    }

#endif
