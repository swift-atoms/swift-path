#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))

    public import Binary

    extension Path: Binary.Serializable {

        /// The path's text, as UTF-8.
        @inlinable
        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ path: borrowing Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(contentsOf: path.string.utf8.map(Byte.init(bitPattern:)))
        }
    }

#endif
