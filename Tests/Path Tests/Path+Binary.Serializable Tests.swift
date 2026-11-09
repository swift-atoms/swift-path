import Binary
import Path
import Testing

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows)

    @Suite
    struct `Path+Binary.Serializable Tests` {

        @Test
        func `serialization writes the stored code units, little-endian, without the NUL`() throws {
            #if os(Windows)
                // A lone high surrogate: not valid UTF-16, so `string` would hold U+FFFD.
                let units: [Path.Char] = [0x0061, 0xD800, 0x0062]
                let expected: [UInt8] = [0x61, 0x00, 0x00, 0xD8, 0x62, 0x00]
            #else
                // 0xFF is never valid UTF-8, so `string` would hold U+FFFD.
                let units: [Path.Char] = [0x61, 0xFF, 0x62]
                let expected: [UInt8] = [0x61, 0xFF, 0x62]
            #endif
            let path = Path(units.span)
            #expect([UInt8](path) == expected)
        }

        @Test
        func `valid text serializes to its encoded code units`() throws {
            let path = try Path(validating: "/tmp/é")
            #if os(Windows)
                let expected: [UInt8] = Swift.Array("/tmp/é".utf16).flatMap { [UInt8($0 & 0xFF), UInt8($0 >> 8)] }
            #else
                let expected: [UInt8] = Swift.Array("/tmp/é".utf8)
            #endif
            #expect([UInt8](path) == expected)
        }
    }

#endif
