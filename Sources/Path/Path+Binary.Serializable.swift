#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Binary

    extension Path: Binary.Serializable {

        /// The path's code units, without the NUL, each little-endian.
        ///
        /// The code units are written as stored, so a path that is not valid in the
        /// platform's encoding round-trips unchanged: bytes on POSIX, UTF-16LE on Windows.
        @inlinable
        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ path: borrowing Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            let units = path.content
            buffer.reserveCapacity(buffer.count + units.count * MemoryLayout<Path.Char>.size)
            for index in units.indices {
                units[index].bytes(into: &buffer, endianness: .little)
            }
        }
    }

#endif
