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

        /// The path that `string` spells, in platform code units.
        ///
        /// Text is held to more than the type's invariant: besides being non-empty and free of NUL,
        /// it may not contain control characters (U+0000–U+001F and U+007F). A path the system hands
        /// back, from `readdir` or `readlink`, may; build those from their code units instead.
        ///
        /// On Windows, `/` in text becomes `\`, so a path holds the platform's own separator.
        @inlinable
        public init(_ string: Swift::String) throws(Path.Error) {
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
                        #if os(Windows)
                            unsafe base[index] = unit == 0x2F ? 0x5C : unit
                        #else
                            unsafe base[index] = unit
                        #endif
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

    extension Path: ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do throws(Path.Error) {
                try self.init(value)
            } catch {
                fatalError("Invalid path literal: \(value) (\(error))")
            }
        }
    }

#endif
