import Path
import Testing

extension `Path Tests` {
    @Suite
    struct Stem {}
}

extension `Path Tests`.Stem {
    @Test
    func `Valid stem parses and retains dots`() throws {
        let stem = try Path.Stem(Swift.String("archive.tar"))
        #expect(stem.string == "archive.tar")
        #expect(Swift.String(stem) == "archive.tar")
        #expect(stem.description == "archive.tar")
    }

    @Test
    func `Invalid stems throw typed errors`() {
        #expect(throws: Path.Stem.Error.empty) {
            try Path.Stem(Swift.String(""))
        }
        #expect(throws: Path.Stem.Error.containsPathSeparator) {
            try Path.Stem(Swift.String("a/b"))
        }
        #expect(throws: Path.Stem.Error.containsControlCharacters) {
            try Path.Stem(Swift.String("a\nb"))
        }
    }

    @Test
    func `String literal initializes stem`() {
        let stem: Path.Stem = "readme"
        #expect(stem.string == "readme")
    }
}
