// A literal is text held to `init(validating:)`. Windows rewrites separators in text, so its conformance sits with that
// rule in Windows 32 Kernel File.
#if PATH_AVAILABLE && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD))

    extension Path: ExpressibleByStringLiteral {

        @inlinable
        public init(stringLiteral value: Swift::String) {
            do throws(Path.Error) {
                try self.init(validating: value)
            } catch {
                fatalError("Invalid path literal: \(value) (\(error))")
            }
        }
    }

    /// Interpolated text is a path by the same rule as a plain literal.
    extension Path: ExpressibleByStringInterpolation {}

#endif
