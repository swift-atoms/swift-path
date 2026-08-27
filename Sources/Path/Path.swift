#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Cardinal
    public import Memory
    public import String
    public import Tagged

    public typealias _CString = String

    @safe
    public struct Path: ~Copyable, @unsafe @unchecked Sendable {

        @usableFromInline
        internal let _storage: Memory.Heap
    }

    extension Path {

        public typealias Char = _CString.Char

        public typealias Codec = _CString.Codec
    }

    extension Path {

        @inlinable
        public init(adopting pointer: UnsafeMutablePointer<Char>, count: Int) {
            #if DEBUG
                precondition(
                    unsafe pointer[count] == _CString.terminator,
                    "Path: adopted buffer must be null-terminated"
                )
            #endif
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(pointer),
                capacity: Memory.Address.Count(_unchecked: Cardinal(UInt(count) * UInt(MemoryLayout<Char>.stride)))
            )
        }

        @inlinable
        public init(copying view: borrowing _CString.Borrowed) {
            let length = view.length
            let buffer = UnsafeMutablePointer<Char>.allocate(capacity: length + 1)
            unsafe buffer.initialize(from: view.pointer, count: length)
            (unsafe buffer)[length] = _CString.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(_unchecked: Cardinal(UInt(length) * UInt(MemoryLayout<Char>.stride)))
            )
        }

        @inlinable
        public init(_ span: Swift.Span<Char>) {
            let length = span.count
            let buffer = UnsafeMutablePointer<Char>.allocate(capacity: length + 1)
            for i in 0..<length {
                (unsafe buffer)[i] = span[i]
            }
            (unsafe buffer)[length] = _CString.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(_unchecked: Cardinal(UInt(length) * UInt(MemoryLayout<Char>.stride)))
            )
        }
    }

    extension Path {

        @unsafe
        @inlinable
        package var _base: UnsafePointer<Char> {

            unsafe UnsafePointer(_storage.unsafeBaseAddress.assumingMemoryBound(to: Char.self))
        }

        @inlinable
        public var count: Int {
            let byteCapacity = Int(bitPattern: _storage.capacity.underlying.rawValue)
            return byteCapacity / MemoryLayout<Char>.stride
        }

        @inlinable
        public var content: Swift.Span<Char> {
            @_lifetime(borrow self) borrowing get {
                let s = unsafe Swift.Span(_unsafeStart: _base, count: count)
                return unsafe _overrideLifetime(s, borrowing: self)
            }
        }
    }

    extension Path {

        @unsafe
        @inlinable
        public consuming func take() -> (pointer: UnsafeMutablePointer<Char>, count: Int) {

            let (raw, byteCapacity) = unsafe _storage.take()
            let count = Int(bitPattern: byteCapacity.underlying.rawValue)
            return unsafe (
                raw.assumingMemoryBound(to: Char.self),
                count / MemoryLayout<Char>.stride
            )
        }
    }

    extension Path {

        public enum ConversionError: Swift.Error, Sendable, Equatable {

            case interiorNUL
        }
    }

#endif
