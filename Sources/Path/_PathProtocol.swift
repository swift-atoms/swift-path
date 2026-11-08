#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    /// What every path offers, whatever owns its memory.
    ///
    /// A conformer stores `count` code units followed by a NUL, and lends them as a
    /// ``Path/Borrowed``. Everything else, written once in extensions, reaches ``Path``,
    /// ``Path/Unique`` and ``Path/Small`` alike, as does the platform grammar at L3.
    ///
    /// Inside an extension, use `view` inline (`view.pointer`, `view.count`, or as an argument):
    /// a `~Copyable` requirement read through a protocol is a borrow and cannot be bound with `let`
    /// (swift-institute/Issues#215).
    public protocol _PathProtocol: ~Copyable {

        /// Creates a path of `count` code units, which `body` initialises; the conformer writes the NUL.
        init(count: Int, initializingWith body: (UnsafeMutablePointer<Path.Char>) -> Void)

        /// The number of code units, without the NUL.
        var count: Int { get }

        /// The code units and their NUL, lent to a system call.
        var view: Path.Borrowed { @_lifetime(borrow self) borrowing get }
    }

    extension Path {

        public typealias `Protocol` = _PathProtocol
    }

#endif

#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import String

    extension _PathProtocol where Self: ~Copyable {

        /// A copy of `view`'s code units.
        @inlinable
        public init(copying view: borrowing Path.Borrowed) {
            let pointer = unsafe view.pointer
            let count = view.count
            unsafe self.init(count: count) { unsafe $0.initialize(from: pointer, count: count) }
        }

        /// A copy of a string's code units.
        @inlinable
        public init(copying view: borrowing String::String.Borrowed) {
            let pointer = unsafe view.pointer
            let count = view.length
            unsafe self.init(count: count) { unsafe $0.initialize(from: pointer, count: count) }
        }

        /// A copy of `span`'s code units.
        @inlinable
        public init(_ span: Swift::Span<Path.Char>) {
            unsafe self.init(count: span.count) { base in
                for index in 0..<span.count {
                    unsafe base[index] = span[index]
                }
            }
        }

        /// `prefix`, then `separator` when one is given, then `suffix`.
        ///
        /// The separator is the caller's choice: which one, and whether one is needed, is grammar.
        @inlinable
        public static func joining(
            _ prefix: borrowing Path.Borrowed,
            separator: Path.Char?,
            _ suffix: borrowing Path.Borrowed
        ) -> Self {
            let gap = separator == nil ? 0 : 1
            let prefixPointer = unsafe prefix.pointer
            let prefixCount = prefix.count
            let suffixPointer = unsafe suffix.pointer
            let suffixCount = suffix.count
            return unsafe Self(count: prefixCount + gap + suffixCount) { base in
                unsafe base.initialize(from: prefixPointer, count: prefixCount)
                if let separator {
                    unsafe base[prefixCount] = separator
                }
                unsafe (base + prefixCount + gap).initialize(from: suffixPointer, count: suffixCount)
            }
        }

        /// The first `count` code units of this path.
        @inlinable
        public borrowing func prefix(_ count: Int) -> Self {
            precondition(count >= 0 && count <= view.count, "Path.prefix: count out of range")
            let pointer = unsafe view.pointer
            return unsafe Self(count: count) { unsafe $0.initialize(from: pointer, count: count) }
        }

        /// The code units from `start` to the end of this path.
        @inlinable
        public borrowing func suffix(from start: Int) -> Self {
            precondition(start >= 0 && start <= view.count, "Path.suffix: start out of range")
            let pointer = unsafe view.pointer + start
            let count = view.count - start
            return unsafe Self(count: count) { unsafe $0.initialize(from: pointer, count: count) }
        }
    }

    extension _PathProtocol where Self: ~Copyable {

        /// The code units, without the NUL.
        @inlinable
        public var content: Swift::Span<Path.Char> {
            @_lifetime(borrow self) borrowing get {
                let span = unsafe Swift::Span<Path.Char>(_unsafeStart: view.pointer, count: view.count)
                return unsafe _overrideLifetime(span, borrowing: self)
            }
        }

        /// The code unit at `index`.
        @inlinable
        public borrowing func unit(at index: Int) -> Path.Char {
            precondition(index >= 0 && index < view.count, "Path.unit(at:): index out of range")
            return unsafe view.pointer[index]
        }

        /// Whether both paths hold the same code units.
        @inlinable
        public borrowing func isEqual<Other: _PathProtocol & ~Copyable>(to other: borrowing Other) -> Bool {
            let count = view.count
            guard count == other.view.count else { return false }
            let lhs = unsafe view.pointer
            let rhs = unsafe other.view.pointer
            for index in 0..<count where unsafe lhs[index] != rhs[index] {
                return false
            }
            return true
        }

        /// Feeds the code units to `hasher`.
        @inlinable
        public borrowing func hashCodeUnits(into hasher: inout Hasher) {
            let count = view.count
            hasher.combine(count)
            unsafe hasher.combine(
                bytes: UnsafeRawBufferPointer(
                    start: view.pointer,
                    count: count * MemoryLayout<Path.Char>.stride
                )
            )
        }
    }

#endif
