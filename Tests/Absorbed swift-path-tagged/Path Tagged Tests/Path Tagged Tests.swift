#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))
import Path
import String
import Tagged
import Testing

@Suite("Path × Tagged")
struct Path_Tests {

    enum TestTag {}

    @Test
    func `copying a string view preserves the path length`() {
        let string = String(ascii: "swift")
        let path = Tagged<TestTag, Path>(copying: string.view)

        #expect(path.count == 5)
    }

    @Test
    func `tagged namespace forwards Path namespaces`() {
        let _: Tagged<TestTag, Path>.ConversionError.Type = Path.ConversionError.self
        let _: Tagged<TestTag, Path>.String.Type = Path.String.self
        let _: Tagged<TestTag, Path>.Resolution.Type = Path.Resolution.self
        let _: Tagged<TestTag, Path>.Canonical.Type = Path.Canonical.self
        let _: Path.String.Scope = Tagged<TestTag, Path>.scope
    }

    @Test
    func `take transfers the tagged path buffer`() {
        let string = String(ascii: "path")
        let path = Tagged<TestTag, Path>(copying: string.view)
        let (pointer, count) = unsafe path.take()
        defer { unsafe pointer.deallocate() }

        #expect(count == 4)
    }
}

#endif
