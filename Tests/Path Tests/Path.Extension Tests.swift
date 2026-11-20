import Path
import Testing

extension `Path Tests` {
    @Suite
    struct Extension {}
}

extension `Path Tests`.Extension {
    @Test
    func `Valid extension parses and converts to string`() throws {
        let ext = try Path.Extension(Swift.String("swift"))
        #expect(ext.string == "swift")
        #expect(Swift.String(ext) == "swift")
        #expect(ext.description == "swift")
    }

    @Test
    func `Invalid extensions throw typed errors`() {
        #expect(throws: Path.Extension.Error.empty) {
            try Path.Extension(Swift.String(""))
        }
        #expect(throws: Path.Extension.Error.containsDot) {
            try Path.Extension(Swift.String("tar.gz"))
        }
        #expect(throws: Path.Extension.Error.containsPathSeparator) {
            try Path.Extension(Swift.String("a/b"))
        }
        #expect(throws: Path.Extension.Error.containsControlCharacters) {
            try Path.Extension(Swift.String("a\nb"))
        }
    }

    @Test
    func `String literal initializes extension`() {
        let ext: Path.Extension = "txt"
        #expect(ext.string == "txt")
    }
}
