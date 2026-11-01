#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import String

    extension Path {

        /// A path stored inline: up to `capacity − 1` code units and the NUL, with no allocation.
        /// A longer path spills to one ``Path`` block.
        @frozen
        @safe
        public struct Small<let capacity: Int>: @unchecked Sendable {

            @usableFromInline
            internal var _inline: InlineArray<capacity, Char>

            @usableFromInline
            internal var _count: Int

            @usableFromInline
            internal var _spill: Path?
        }
    }

    extension Path.Small: Path.`Protocol` {

        @inlinable
        public init(count: Int, initializingWith body: (UnsafeMutablePointer<Path.Char>) -> Void) {
            var inline = InlineArray<capacity, Path.Char>(repeating: String::String.terminator)
            if count < capacity {
                var units = inline.mutableSpan
                units.withUnsafeMutableBufferPointer { buffer in
                    guard let base = buffer.baseAddress else { return }
                    unsafe body(base)
                }
                self._spill = nil
            } else {
                self._spill = unsafe Path(count: count, initializingWith: body)
            }
            self._inline = inline
            self._count = count
        }

        @inlinable
        public var count: Int { _count }

        @inlinable
        public var view: Path.Borrowed {
            @_lifetime(borrow self) borrowing get {
                if let spill = _spill {
                    let pointer = unsafe spill._storage.withUnsafeMutablePointerToElements { unsafe UnsafePointer($0) }
                    let view = unsafe Path.Borrowed(pointer, count: _count)
                    return unsafe _overrideLifetime(view, borrowing: self)
                }
                let pointer = _inline.span.withUnsafeBufferPointer { buffer in
                    guard let base = buffer.baseAddress else {
                        preconditionFailure("Path.Small: inline storage always holds the NUL")
                    }
                    return unsafe base
                }
                let view = unsafe Path.Borrowed(pointer, count: _count)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }

    extension Path.Small: Hashable {

        @inlinable
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.isEqual(to: rhs)
        }

        @inlinable
        public func hash(into hasher: inout Hasher) {
            hashCodeUnits(into: &hasher)
        }
    }

    extension Path.Small: CustomStringConvertible, CustomDebugStringConvertible {

        public var description: Swift::String { string }

        public var debugDescription: Swift::String { "Path.Small(\"\(string)\")" }
    }

#endif
