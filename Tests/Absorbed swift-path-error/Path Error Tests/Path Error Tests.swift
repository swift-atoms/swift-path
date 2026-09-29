#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows))
import Error
import Path
import Testing

@Suite("Path.Canonical × Error")
struct Path_Tests {

    @Test
    func `path failures preserve resolution identity and description`() {
        let failure = Path.Canonical.Error.path(.notFound)

        #expect(failure == .path(.notFound))
        #expect(failure != .path(.exists))
        #expect(failure.description == "path canonicalization: not found")
    }

    @Test
    func `platform failures preserve the Error value`() {
        let failure = Path.Canonical.Error.platform(Error(code: .posix(2)))

        #expect(failure == .platform(Error(code: .posix(2))))
        #expect(failure != .platform(Error(code: .posix(3))))
        #expect(failure.description.hasPrefix("path canonicalization: "))
    }

    @Test
    func `failure domains are unequal`() {
        #expect(
            Path.Canonical.Error.path(.notFound)
                != .platform(Error(code: .posix(2)))
        )
    }
}

#endif
