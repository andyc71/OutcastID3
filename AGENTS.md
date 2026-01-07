# Repository Guidelines

## Project Structure & Module Organization
- `Sources/OutcastID3/` holds the core Swift library sources.
- `Tests/OutcastID3Tests/` contains XCTest suites and fixtures.
- `Tests/OutcastID3Tests/TestData/` stores MP3/JPG/PNG assets used by tests.
- `Example/` includes sample iOS and console apps plus Xcode project files.
- `Package.swift` defines Swift Package Manager targets and dependencies.

## Build, Test, and Development Commands
- `swift build` builds the library via Swift Package Manager.
- `swift test` runs the XCTest suite and copies test resources.
- `swift test --filter OutcastID3Tests.SomeTest` runs a focused test class.
- `open Example/OutcastID3.xcodeproj` opens the sample apps in Xcode.
- `cd Example && pod install` installs CocoaPods for the example app (if using CocoaPods).

## Coding Style & Naming Conventions
- Use Swift standard formatting: 4-space indentation, no tabs.
- Types use `UpperCamelCase`; methods/properties use `lowerCamelCase`.
- Keep file names aligned with the primary type (e.g., `MP3File.swift`).
- Prefer Swift API Design Guidelines for labeling and clarity.

## Testing Guidelines
- Tests use `XCTest` with `SnapshotTesting` for data comparisons.
- Name tests in `*Tests.swift` and keep fixtures in `TestData/`.
- When adding fixtures, keep filenames descriptive and stable.

## Commit & Pull Request Guidelines
- Recent history uses short, imperative, sentence-case messages (e.g., "Fix ID3 string parsing").
- PRs should include a concise description, testing notes, and any relevant issue links.
- Include screenshots for UI changes in the Example app.

## Configuration Notes
- Swift tools version is `5.6` (see `Package.swift`).
- SwiftLint is currently disabled in the package manifest.
