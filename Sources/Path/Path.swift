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

    extension Path: Path.`Protocol` {

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
