#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    extension Path {

        public struct Extension: Copyable, Sendable, Hashable {

            @usableFromInline
            internal let _value: Swift::String

            @inlinable
            public init(unchecked value: Swift::String) {
                self._value = value
            }
        }
    }

    extension Path.Extension {

        @inlinable
        public init(_ string: Swift::String) throws(Error) {
            guard !string.isEmpty else {
                throw .empty
            }

            for byte in string.utf8 {
                if byte == 0x2E {
                    throw .containsDot
                }

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
        public init(_ ext: Path.Extension) {
            self = ext.string
        }
    }

    extension Path.Extension: CustomStringConvertible {
        public var description: Swift::String {
            string
        }
    }

    extension Path.Extension: CustomDebugStringConvertible {
        public var debugDescription: Swift::String {
            "Path.Extension(\"\(string)\")"
        }
    }

    extension Path.Extension: ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do throws(Error) {
                try self.init(value)
            } catch {
                preconditionFailure("Invalid extension literal: \(value) (\(error))")
            }
        }
    }

#endif
