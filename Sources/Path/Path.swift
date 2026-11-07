#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import String

    /// A path: platform code units, NUL-terminated, with no interior NUL.
    ///
    /// `Path` is the default conformer of ``Path/Protocol``: copyable, hashable and sendable, on one
    /// tail-allocated block, so a copy is a retain. ``Path/Unique`` is the single-owner store and
    /// ``Path/Small`` the inline one. What the separators mean is the platform's grammar, which
    /// swift-iso-9945 and swift-windows-32 add.
    @frozen
    @safe
    public struct Path: @unchecked Sendable {

        @usableFromInline
        internal let _storage: ManagedBuffer<Int, Char>
    }

    extension Path {

        public typealias Char = String::String.Char

        public typealias Codec = String::String.Codec
    }

    extension Path: _PathProtocol {

        @inlinable
        public init(count: Int, initializingWith body: (UnsafeMutablePointer<Char>) -> Void) {
            let storage = ManagedBuffer<Int, Char>.create(minimumCapacity: count + 1) { _ in count }
            unsafe storage.withUnsafeMutablePointerToElements { base in
                unsafe body(base)
                unsafe base[count] = String::String.terminator
            }
            self._storage = storage
        }

        @inlinable
        public var count: Int { _storage.header }

        @inlinable
        public var view: Borrowed {
            @_lifetime(borrow self) borrowing get {
                let base = unsafe _storage.withUnsafeMutablePointerToElements { unsafe UnsafePointer($0) }
                let view = unsafe Borrowed(base, count: _storage.header)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }

    extension Path: Hashable {

        @inlinable
        public static func == (lhs: Path, rhs: Path) -> Bool {
            lhs._storage === rhs._storage || lhs.isEqual(to: rhs)
        }

        @inlinable
        public func hash(into hasher: inout Hasher) {
            hashCodeUnits(into: &hasher)
        }
    }

#endif

#if !hasFeature(Embedded) && PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

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

#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD))

    extension Path: ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do throws(Path.Error) {
                try self.init(validating: value)
            } catch {
                fatalError("Invalid path literal: \(value) (\(error))")
            }
        }
    }

    /// Interpolated text is a path by the same rule as a plain literal.
    extension Path: ExpressibleByStringInterpolation {}

#endif

#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))
    extension Path {

        public static func sanitized(from source: Swift::String) -> Swift::String {
            var sanitized = ""
            sanitized.reserveCapacity(source.count)
            for character in source {
                if character.isLetter || character.isNumber
                    || character == "_" || character == "-" || character == "."
                {
                    sanitized.append(character)
                } else {
                    sanitized.append("_")
                }
            }
            return sanitized
        }
    }

#endif
