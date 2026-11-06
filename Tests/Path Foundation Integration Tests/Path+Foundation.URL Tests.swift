import Foundation
import Path_Foundation_Integration
import Testing

enum `Path Tests` {}

extension `Path Tests` {
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

extension `Path Tests`.`Foundation URL`.Unit {
    @Test func `a file URL becomes its path and back`() throws {
        let url = URL(filePath: `Path Tests`.`Foundation URL`.file)
        let path = try Path(url)
        #expect(path.string == `Path Tests`.`Foundation URL`.file)
        #expect(URL(path) == url)
    }
}

extension `Path Tests`.`Foundation URL`.`Edge Case` {
    @Test func `a folder URL's trailing separator is dropped`() throws {
        let url = URL(filePath: `Path Tests`.`Foundation URL`.folder, directoryHint: .isDirectory)
        #expect(try Path(url).string == `Path Tests`.`Foundation URL`.folder)
    }

    @Test func `the root stays the root`() throws {
        let url = URL(filePath: `Path Tests`.`Foundation URL`.root, directoryHint: .isDirectory)
        #expect(try Path(url).string == `Path Tests`.`Foundation URL`.root)
    }
}
