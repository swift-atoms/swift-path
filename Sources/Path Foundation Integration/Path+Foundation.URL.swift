public import Foundation
public import Path

extension Path {

    /// The path a file URL names, read through the platform's own file-system representation, so a
    /// Windows URL gives `C:\…` with its own separators. A folder's trailing separator is dropped.
    public init(_ url: Foundation.URL) throws(Path.Error) {
        let native = unsafe url.withUnsafeFileSystemRepresentation { unsafe $0.map { unsafe Swift.String(cString: $0) } }
        try self.init(Self.folder(native ?? url.path(percentEncoded: false)))
    }

    static func folder(_ string: Swift.String) -> Swift.String {
        var string = string
        while string.count > 1, let last = string.last, last == "/" || last == "\\",
            string.dropLast().last != ":"
        {
            string.removeLast()
        }
        return string
    }
}
