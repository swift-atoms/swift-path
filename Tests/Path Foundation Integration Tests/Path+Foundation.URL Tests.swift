import Foundation
import Path_Foundation_Integration
import Testing

extension Path {
    @Suite struct `Foundation URL` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}

        #if os(Windows)
            static let file = #"C:\Users\a\Letters\Rekening maart.pdf"#
            static let folder = #"C:\Users\a\Letters"#
            static let root = #"C:\"#
        #else
            static let file = "/Users/a/Letters/Rekening maart.pdf"
            static let folder = "/Users/a/Letters"
            static let root = "/"
        #endif
    }
}

extension Path.`Foundation URL`.Unit {
    @Test func `a file URL becomes its path and back`() throws {
        let url = URL(filePath: Path.`Foundation URL`.file)
        let path = try Path(url)
        #expect(path.string == Path.`Foundation URL`.file)
        #expect(URL(path) == url)
    }
}

extension Path.`Foundation URL`.`Edge Case` {
    @Test func `a folder URL's trailing separator is dropped`() throws {
        let url = URL(filePath: Path.`Foundation URL`.folder, directoryHint: .isDirectory)
        #expect(try Path(url).string == Path.`Foundation URL`.folder)
    }

    @Test func `the root stays the root`() throws {
        let url = URL(filePath: Path.`Foundation URL`.root, directoryHint: .isDirectory)
        #expect(try Path(url).string == Path.`Foundation URL`.root)
    }
}
