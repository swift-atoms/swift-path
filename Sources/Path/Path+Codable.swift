#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    /// A path in a persisted format is its text, held to ``Path/Protocol/init(validating:)``. A path the system hands
    /// back may not survive this, since it may hold code units that aren't text: that stays a matter of its code units.
    extension Path: Swift::Codable {

        public init(from decoder: any Swift::Decoder) throws {
            try self.init(validating: try decoder.singleValueContainer().decode(Swift::String.self))
        }

        public func encode(to encoder: any Swift::Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(string)
        }
    }

#endif
