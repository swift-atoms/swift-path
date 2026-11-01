import Path
import Testing

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows)

    @Suite("Path.Protocol")
    struct Path_Protocol_Tests {

        @Test
        func `text round-trips through every store`() throws {
            let shared = try Path(Swift.String("/tmp/a b"))
            let unique = try Path.Unique("/tmp/a b")
            let small = try Path.Small<256>("/tmp/a b")
            let spilled = try Path.Small<4>("/tmp/a b")
            #expect(shared.string == "/tmp/a b")
            #expect(unique.string == "/tmp/a b")
            #expect(small.string == "/tmp/a b")
            #expect(spilled.string == "/tmp/a b")
        }

        @Test
        func `text rejects empty, NUL and control characters`() {
            // `Path("…")` with a literal is a literal coercion, which traps; text from a value throws.
            let texts: [(Swift.String, Path.Error)] = [
                ("", .empty),
                ("a\u{0}b", .containsInteriorNUL),
                ("a\nb", .containsControlCharacters),
                ("a\u{7F}", .containsControlCharacters),
            ]
            for (text, error) in texts {
                #expect(throws: error) { _ = try Path(text) }
                #expect(throws: error) { _ = try Path.Unique(text).count }
            }
        }

        @Test
        func `the view is NUL-terminated and counts code units`() throws {
            let path: Path = "/tmp/é"
            let view = path.view
            #expect(view.count == path.count)
            #expect(unsafe view.pointer[view.count] == 0)
            #if os(Windows)
                #expect(path.count == "/tmp/é".utf16.count)
            #else
                #expect(path.count == "/tmp/é".utf8.count)
            #endif
        }

        @Test
        func `a copy shares its storage and compares equal`() throws {
            let a: Path = "/usr/lib"
            let b = a
            #expect(a == b)
            #expect(a.hashValue == b.hashValue)
            #expect(Set([a, b, "/usr/lib"]).count == 1)
            #expect(a != "/usr/libx")
        }

        @Test
        func `joining puts the separator between, when one is given`() throws {
            let a: Path = "/usr"
            let b: Path = "lib"
            #expect(Path.joining(a.view, separator: 0x2F, b.view) == "/usr/lib")
            #expect(Path.joining(a.view, separator: nil, b.view) == "/usrlib")
        }

        @Test
        func `prefix and suffix copy code units`() {
            let path: Path = "/usr/lib"
            #expect(path.prefix(4) == "/usr")
            #expect(path.suffix(from: 5) == "lib")
        }

        @Test
        func `isEqual compares across stores`() throws {
            let shared: Path = "/a/b"
            let unique = try Path.Unique("/a/b")
            let small = try Path.Small<8>("/a/b")
            let sharedUnique = shared.isEqual(to: unique)
            let uniqueSmall = unique.isEqual(to: small)
            let smallShared = small.isEqual(to: shared)
            #expect(sharedUnique)
            #expect(uniqueSmall)
            #expect(smallShared)
        }
    }

    @Suite("Path.Unique")
    struct Path_Unique_Tests {

        @Test
        func `push grows the buffer and truncate keeps it`() throws {
            var path = try Path.Unique("/root")
            let name: Path = "child"
            path.push(name.view, separator: 0x2F)
            #expect(path.string == "/root/child")
            #expect(unsafe path.view.pointer[path.count] == 0)
            path.truncate(to: 5)
            #expect(path.string == "/root")
            path.push(name.view, separator: 0x2F)
            path.push(name.view, separator: 0x2F)
            #expect(path.string == "/root/child/child")
        }

        @Test
        func `take hands the buffer back, and adopting takes it again`() throws {
            let path = try Path.Unique("/x")
            let (pointer, count) = unsafe path.take()
            #expect(count == 2)
            let again = unsafe Path.Unique(adopting: pointer, count: count)
            #expect(again.string == "/x")
            let shared = again.shared()
            #expect(shared == "/x")
        }
    }

    @Suite("Path.Small")
    struct Path_Small_Tests {

        @Test
        func `short paths stay inline, long ones spill`() throws {
            let short = try Path.Small<8>("/a/b")
            let long = try Path.Small<8>("/a/b/c/d/e")
            #expect(short.count == 4)
            #expect(long.count == 10)
            #expect(unsafe short.view.pointer[short.count] == 0)
            #expect(unsafe long.view.pointer[long.count] == 0)
            let shortAgain = try Path.Small<8>("/a/b")
            let longAgain = try Path.Small<8>("/a/b/c/d/e")
            #expect(short == shortAgain)
            #expect(long == longAgain)
        }

        @Test
        func `a path one short of capacity is inline; at capacity it spills`() throws {
            let inline = try Path.Small<4>("abc")
            let spilled = try Path.Small<4>("abcd")
            #expect(inline.string == "abc")
            #expect(spilled.string == "abcd")
        }
    }

#endif
