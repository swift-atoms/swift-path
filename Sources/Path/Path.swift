#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import String
    public import Memory

    @safe
    public struct Path: ~Copyable, @unsafe @unchecked Sendable {

        @usableFromInline
        internal let _storage: Memory.Heap
    }

    extension Path {

        public typealias Char = String.String.Char

        public typealias Codec = String.String.Codec
    }

    extension Path {

        @inlinable
        public init(adopting pointer: UnsafeMutablePointer<Char>, count: Int) {
            #if DEBUG
                precondition(
                    unsafe pointer[count] == String.String.terminator,
                    "Path: adopted buffer must be null-terminated"
                )
            #endif
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(pointer),
                capacity: Memory.Address.Count(UInt(count) * UInt(MemoryLayout<Char>.stride))
            )
        }

        @inlinable
        public init(copying view: borrowing String.String.Borrowed) {
            let length = view.length
            let buffer = UnsafeMutablePointer<Char>.allocate(capacity: length + 1)
            unsafe buffer.initialize(from: view.pointer, count: length)
            (unsafe buffer)[length] = String.String.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(UInt(length) * UInt(MemoryLayout<Char>.stride))
            )
        }

        @inlinable
        public init(_ span: Swift.Span<Char>) {
            let length = span.count
            let buffer = UnsafeMutablePointer<Char>.allocate(capacity: length + 1)
            for i in 0..<length {
                (unsafe buffer)[i] = span[i]
            }
            (unsafe buffer)[length] = String.String.terminator
            unsafe self._storage = Memory.Heap(
                adopting: UnsafeMutableRawPointer(buffer),
                capacity: Memory.Address.Count(UInt(length) * UInt(MemoryLayout<Char>.stride))
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
            let byteCapacity = Int(bitPattern: _storage.capacity)
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
            let count = Int(bitPattern: byteCapacity)
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
