#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import String

    extension Path {

        /// A path with a single owner: `~Copyable`, on one heap buffer it frees when it ends.
        ///
        /// It adopts a buffer a system call allocated, hands its buffer back with ``take()``, and
        /// grows in place with ``push(_:separator:)`` and ``truncate(to:)``, so a walk can reuse one
        /// buffer for every entry.
        @frozen
        @safe
        public struct Unique: ~Copyable, @unsafe @unchecked Sendable {

            @usableFromInline
            internal var _base: UnsafeMutablePointer<Char>

            @usableFromInline
            internal var _count: Int

            /// Code units the buffer holds, without the NUL's slot.
            @usableFromInline
            internal var _capacity: Int

            @inlinable
            @unsafe
            internal init(_base base: UnsafeMutablePointer<Char>, count: Int, capacity: Int) {
                unsafe (self._base = base)
                self._count = count
                self._capacity = capacity
            }

            deinit {
                unsafe _base.deallocate()
            }
        }
    }

    extension Path.Unique: Path.`Protocol` {

        @inlinable
        public init(count: Int, initializingWith body: (UnsafeMutablePointer<Path.Char>) -> Void) {
            let base = UnsafeMutablePointer<Path.Char>.allocate(capacity: count + 1)
            unsafe body(base)
            unsafe base[count] = String::String.terminator
            unsafe self.init(_base: base, count: count, capacity: count)
        }

        @inlinable
        public var count: Int { _count }

        @inlinable
        public var view: Path.Borrowed {
            @_lifetime(borrow self) borrowing get {
                let view = unsafe Path.Borrowed(UnsafePointer(_base), count: _count)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }

    extension Path.Unique {

        /// Takes ownership of a NUL-terminated buffer of `count` code units, allocated with
        /// `UnsafeMutablePointer.allocate`.
        @inlinable
        public init(adopting pointer: UnsafeMutablePointer<Path.Char>, count: Int) {
            #if DEBUG
                precondition(
                    unsafe pointer[count] == String::String.terminator,
                    "Path.Unique: adopted buffer must be null-terminated"
                )
            #endif
            unsafe self.init(_base: pointer, count: count, capacity: count)
        }

        /// Hands the buffer to the caller, who deallocates it.
        @unsafe
        @inlinable
        public consuming func take() -> (pointer: UnsafeMutablePointer<Path.Char>, count: Int) {
            let result = unsafe (_base, _count)
            discard self
            return unsafe result
        }

        /// A copyable copy of this path.
        @inlinable
        public borrowing func shared() -> Path {
            Path(copying: view)
        }
    }

    extension Path.Unique {

        /// Appends `separator`, when one is given, then `suffix`, growing the buffer when needed.
        @inlinable
        public mutating func push(_ suffix: borrowing Path.Borrowed, separator: Path.Char?) {
            let gap = separator == nil ? 0 : 1
            let total = _count + gap + suffix.count
            if total > _capacity {
                let capacity = Swift::max(total, _capacity * 2)
                let base = UnsafeMutablePointer<Path.Char>.allocate(capacity: capacity + 1)
                unsafe base.moveInitialize(from: _base, count: _count)
                unsafe _base.deallocate()
                unsafe (_base = base)
                _capacity = capacity
            }
            if let separator {
                unsafe _base[_count] = separator
            }
            unsafe (_base + _count + gap).initialize(from: suffix.pointer, count: suffix.count)
            _count = total
            unsafe _base[_count] = String::String.terminator
        }

        /// Shortens the path to its first `count` code units, keeping the buffer.
        @inlinable
        public mutating func truncate(to count: Int) {
            precondition(count >= 0 && count <= _count, "Path.Unique.truncate: count out of range")
            _count = count
            unsafe _base[_count] = String::String.terminator
        }
    }

#endif
