#if canImport(Foundation)

    public import Foundation
    public import Path

    extension Foundation.URL {

        /// The file URL of `path`.
        public init(_ path: Path) {
            self.init(filePath: path.string)
        }
    }

#endif
