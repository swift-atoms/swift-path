#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension Path {

        /// Why text is not a path.
        public enum Error: Swift::Error, Sendable, Equatable, Hashable {

            case empty

            case containsControlCharacters

            case containsInteriorNUL
        }
    }

    extension Path.Error: CustomStringConvertible {

        public var description: Swift::String {
            switch self {
            case .empty: return "Path is empty"
            case .containsControlCharacters: return "Path contains control characters"
            case .containsInteriorNUL: return "Path contains interior NUL"
            }
        }
    }

    extension _PathProtocol where Self: ~Copyable {

        /// The code units that `string` encodes, unchanged.
        ///
        /// Text is held to more than the type's invariant: besides being non-empty and free of NUL,
        /// it may not contain control characters (U+0000–U+001F and U+007F). A path the system hands
        /// back, from `readdir` or `readlink`, may; build those from their code units instead.
        ///
        /// Separators are not interpreted: that is the platform grammar's work. Its `init(_:)`,
        /// in swift-iso-9945 or swift-windows-32, is the entry point for text.
        @inlinable
        public init(validating string: Swift::String) throws(Path.Error) {
            guard !string.isEmpty else { throw .empty }
            var count = 0
            for scalar in string.unicodeScalars {
                if scalar.value == 0 { throw .containsInteriorNUL }
                if scalar.value < 0x20 || scalar.value == 0x7F { throw .containsControlCharacters }
                if let units = Path.Codec.encode(scalar) {
                    count += units.count
                }
            }
            unsafe self.init(count: count) { base in
                var index = 0
                for scalar in string.unicodeScalars {
                    guard let units = Path.Codec.encode(scalar) else { continue }
                    for unit in units {
                        unsafe base[index] = unit
                        index += 1
                    }
                }
            }
        }

        /// The path as text. Code units that are not valid in the platform's encoding become U+FFFD.
        @inlinable
        public var string: Swift::String {
            let buffer = unsafe UnsafeBufferPointer(start: view.pointer, count: view.count)
            return unsafe Swift::String(decoding: buffer, as: Path.Codec.self)
        }
    }

    extension Swift::String {

        /// The text of `path`.
        @inlinable
        public init<P: _PathProtocol & ~Copyable>(_ path: borrowing P) {
            self = path.string
        }
    }

    extension Path: CustomStringConvertible, CustomDebugStringConvertible {

        public var description: Swift::String { string }

        public var debugDescription: Swift::String { "Path(\"\(string)\")" }
    }

#endif
