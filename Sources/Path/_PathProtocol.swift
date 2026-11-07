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
