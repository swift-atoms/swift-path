#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD))

    extension Path {

        /// A path's components, in order, without separators.
        public struct Components: Sendable {

            public let path: Path

            @inlinable
            public init(_ path: Path) {
                self.path = path
            }
        }
    }

#endif
