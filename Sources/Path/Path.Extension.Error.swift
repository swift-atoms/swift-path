#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension Path.Extension {

        public enum Error: Swift::Error, Sendable, Equatable {

            case empty

            case containsDot

            case containsPathSeparator

            case containsControlCharacters
        }
    }

    extension Path.Extension.Error: CustomStringConvertible {
        public var description: Swift::String {
            switch self {
            case .empty:
                return "Extension is empty"

            case .containsDot:
                return "Extension contains dot"

            case .containsPathSeparator:
                return "Extension contains path separator"

            case .containsControlCharacters:
                return "Extension contains control characters"
            }
        }
    }

#endif
