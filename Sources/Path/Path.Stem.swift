#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension Path {

        public struct Stem: Copyable, Sendable, Hashable {

            @usableFromInline
            internal let _value: Swift::String

            @inlinable
            public init(unchecked value: Swift::String) {
                self._value = value
            }
        }
    }

    extension Path.Stem {

        @inlinable
        public init(_ string: Swift::String) throws(Error) {
            guard !string.isEmpty else {
                throw .empty
            }

            for byte in string.utf8 {
                #if os(Windows)
                    if byte == 0x2F || byte == 0x5C {
                        throw .containsPathSeparator
                    }
                #else
                    if byte == 0x2F {
                        throw .containsPathSeparator
                    }
                #endif

                if byte < 0x20 || byte == 0x7F {
                    throw .containsControlCharacters
                }
            }

            self.init(unchecked: string)
        }

        @inlinable
        public var string: Swift::String {
            _value
        }
    }

    extension Swift::String {

        @inlinable
        public init(_ stem: Path.Stem) {
            self = stem.string
        }
    }

    extension Path.Stem: CustomStringConvertible {
        public var description: Swift::String {
            string
        }
    }

    extension Path.Stem: CustomDebugStringConvertible {
        public var debugDescription: Swift::String {
            "Path.Stem(\"\(string)\")"
        }
    }

    extension Path.Stem: ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do throws(Error) {
                try self.init(value)
            } catch {
                preconditionFailure("Invalid stem literal: \(value) (\(error))")
            }
        }
    }

#endif
