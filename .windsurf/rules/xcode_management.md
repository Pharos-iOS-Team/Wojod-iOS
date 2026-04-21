# Xcode Project Management

## File System Changes

Whenever a file is **added, moved, or deleted** in the project, the Xcode project file must be updated accordingly:

- **Added files**: Must be added to the appropriate target in the Xcode project (`Wojood.xcodeproj`). Open the `.xcodeproj` in Xcode and drag the file into the project navigator, or use File → Add Files.
- **Moved files**: References must be updated in the Xcode project to reflect new paths
- **Deleted files**: Must be removed from the Xcode project to avoid broken references — delete both from disk AND from the project navigator

This ensures:
- Proper compilation and linking
- Accurate file organization in Xcode navigator
- No broken references or missing files during build
- Consistency between file system and project structure

## SwiftGen Regeneration

After adding or renaming any resource files (images, colors, fonts, storyboards, localizations), always run:
```bash
swiftgen
```
This regenerates type-safe accessors in `App/Generated/SwiftGen/`.

## SwiftLint

The project uses SwiftLint with extensive opt-in rules (see `.swiftlint.yml`). Key rules:
- File headers must include copyright notice
- File names must match primary type
- Enforced type ordering within files
- Line length limit of 160 characters
