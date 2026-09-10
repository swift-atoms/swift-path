#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Tagged
    import String

    extension Tagged where Underlying == Path, Tag: ~Copyable & ~Escapable {

        public typealias ConversionError = Path.ConversionError

        public typealias String = Path.String

        public typealias Resolution = Path.Resolution

        public typealias Canonical = Path.Canonical
    }

    extension Tagged where Underlying == Path, Tag: ~Copyable & ~Escapable {

        @inlinable
        public static var scope: Path.String.Scope { Path.String.Scope() }
    }

    extension Tagged where Underlying == Path, Tag: ~Copyable & ~Escapable {

        @inlinable
        public init(adopting pointer: UnsafeMutablePointer<Path.Char>, count: Int) {
            unsafe self.init(_unchecked: Path(_storage: <#Memory.Heap#>, adopting: pointer, count: count))
        }

        @inlinable
        public init(copying view: borrowing String.String.Borrowed) {
            self.init(_unchecked: Path(_storage: view))
        }

        @inlinable
        public init(_ span: Swift.Span<Path.Char>) {
            self.init(_unchecked: Path(_storage: span))
        }
    }

    extension Tagged where Underlying == Path, Tag: ~Copyable & ~Escapable {

        @inlinable
        public var count: Int { underlying.count }

    }

    extension Tagged where Underlying == Path, Tag: ~Copyable & ~Escapable {

        @unsafe
        @inlinable
        public consuming func take() -> (pointer: UnsafeMutablePointer<Path.Char>, count: Int) {
            self.map { (p: consuming Path) in unsafe p.take() }.underlying
        }
    }

#endif
