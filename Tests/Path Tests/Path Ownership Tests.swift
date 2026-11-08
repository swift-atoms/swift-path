import Ownership
import Path
import Testing

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD) || os(Windows)

    @Suite
    struct Path_Ownership_Tests {

        @Test
        func `Path conforms to Ownership.Borrow.Protocol`() {
            requireBorrowProtocol(Path.self)
        }

        @Test
        func `Path's borrowed representation is Path.Borrowed`() {
            let type: Path.Borrowed.Type = resolveBorrowedType(Path.self)
            _ = type
        }
    }

    private func requireBorrowProtocol<T: Ownership.Borrow.`Protocol` & ~Copyable>(_: T.Type) {}

    private func resolveBorrowedType<T: Ownership.Borrow.`Protocol` & ~Copyable>(
        _: T.Type
    ) -> T.Borrowed.Type {
        T.Borrowed.self
    }

#endif
