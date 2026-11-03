# swift-path

Use this package when you need to hold a file-system path as the platform's own code units and pass it to a system call, with no opinion about what the separators mean. Start from `Path` (copyable). Use `Path.Unique` when one owner adopts or hands back a system buffer, or reuses one buffer through a directory walk. Use `Path.Small<capacity>` to keep short paths off the heap. Generic code takes `Path.Protocol`. To turn text into a path through the platform's grammar, use swift-iso-9945 or swift-windows-32. For components, extensions, parents and appending, use swift-paths. Add Path Foundation Integration to convert to and from `Foundation.URL`.

## Laws

- A path is a sequence of code units followed by a NUL: UTF-8 everywhere except Windows, where it is UTF-16. `count` counts code units, not characters, and never includes the NUL.
- This package never reads separators. `init(validating:)` stores the code units of the text exactly as given, and `joining(_:separator:_:)` and `Path.Unique.push(_:separator:)` insert only the separator the caller passes, or none for `nil`.
- `init(validating:)` rejects text that is empty, contains U+0000, or contains a control character (U+0001–U+001F or U+007F). Paths the system returns may contain control characters. Build those from their code units, not from text.
- `Path.String.Scope` (`Path.scope`) rejects only interior NULs. Its `index` is the string's position among the arguments, and for two arrays the second array's positions continue after the first. Its buffers exist only while the closure runs.
- `string` decodes the code units. Units that are invalid in the platform's encoding become U+FFFD, so converting a path to text and back is lossless only for paths that are valid text. `Path`'s binary serialization is the UTF-8 of `string`, so it is just as lossy.
- Equality and hashing compare code units. They do no normalization, case folding or separator folding. `isEqual(to:)` compares `Path`, `Path.Unique` and `Path.Small` with each other.
- Copying a `Path` shares its storage, and copies compare equal without reading the code units.
- `Path.Small<capacity>` stores a path inline when it has at most `capacity − 1` code units. A longer path spills into one `Path` block.
- `Path.Unique.push(_:separator:)` grows the buffer to the larger of the needed size and twice the current capacity. `truncate(to:)` keeps the buffer. `take()` hands the buffer to the caller, who must deallocate it. `init(adopting:count:)` takes a buffer from `UnsafeMutablePointer.allocate` with a NUL at `count`. Debug builds check that NUL; release builds do not.
- In debug builds, `Path.Borrowed` checks that a NUL appears within 16 Mi code units.
- `Path(_:)` from a `Foundation.URL` reads the platform's file-system representation, so a Windows URL gives `C:\…`. It drops trailing separators but leaves `/` and a drive root such as `C:\` alone.
- `Path.sanitized(from:)` keeps letters, numbers, `_`, `-` and `.`, and turns every other `Character` into one `_`. Different inputs can give the same output: `a/b` and `a_b` both give `a_b`.
