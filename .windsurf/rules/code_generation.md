# Code Generation Rules

## SwiftGen Usage — No Raw Strings, Ever

Every asset, color, storyboard, font, or localization reference **must** use SwiftGen-generated accessors. Raw strings are banned.

### Asset Access
- **Images**: `Asset.Images.someImage.image` — one canonical form, no alternatives
- **Colors**: `Asset.Colors.someColor.color`

### Storyboard Access
- `StoryboardScene.[Feature].viewController.instantiate()`
- Example: `StoryboardScene.Login.initialScene.instantiate()`
- Example: `StoryboardScene.VerifyOtp.verifyOtpViewController.instantiate()`

### Localization Access
- **Module-scoped**: `L10n.[Feature].[Key]` (e.g., `L10n.Login.signIn`, `L10n.CourseDetails.Main.contactUs`)
- **Global**: `L10n.Global.Actions.cancel`, `L10n.Global.Titles.error`, `L10n.Global.Alerts.loading`
- ❌ **BANNED**: `.localiz()` helper or `NSLocalizedString` — always use `L10n.*`

## Banned Patterns

| Banned | Use Instead |
|--------|-------------|
| `UIImage(named: "BackIcon")` | `Asset.Images.backIcon.image` |
| `UIColor(named: "sendButtonColor")` | `Asset.Colors.sendButtonColor.color` |
| `UIFont(name: "Tajawal", size: 16)` | `FontFamily.Tajawal.regular.font(size: 16)` |
| `"some.key".localiz()` | `L10n.Some.key` |
| `NSLocalizedString("key", comment: "")` | `L10n.Some.key` |
| `UIStoryboard(name: "Login", bundle: nil)` | `StoryboardScene.Login.initialScene.instantiate()` |

## Regeneration Requirements

Run `swiftgen` after adding/renaming **any** of the following:
- ✅ Images, color sets, or other asset catalog items
- ✅ New color definitions in asset catalogs
- ✅ New storyboards or updated storyboard identifiers
- ✅ New or modified `.strings` files
- ✅ New font files in the Fonts directory

```bash
swiftgen
```

## File Structure

Generated SwiftGen files are located in:
- `App/Generated/SwiftGen/Assets.swift` — Image and color accessors
- `App/Generated/SwiftGen/Fonts.swift` — Font accessors
- `App/Generated/SwiftGen/Storyboards.swift` — Storyboard accessors
- `App/Generated/SwiftGen/Strings/Strings.swift` — Module-scoped localization
- `App/Generated/SwiftGen/Strings/GlobalStrings.swift` — Global localization (extends `L10n.Global`)

## SwiftGen Configuration

Configured in `swiftgen.yml` at project root:
- **Storyboards**: scans `App/Sources/` using `scenes-swift4` template
- **Assets**: scans `App/Resources/Images.xcassets` + `Colors.xcassets` using `swift4` template
- **Fonts**: scans `App/Resources/Fonts` using `swift4` template
- **Strings**: uses custom stencils (`dn-structured-swift5.stencil`, `extension-structured-swift5.stencil`)
  - `Localizable.strings` → `Strings.swift` (module keys)
  - `GlobalLocalizable.strings` → `GlobalStrings.swift` (extends `L10n.Global`)

## Verification Before Use — No Guessing

**CRITICAL**: Before using any model property or localization key:

1. **Models**: Read the actual model file to verify property names
   - ❌ DON'T guess (e.g., `video.url` → actually `video.fileUrl`)
   - ✅ DO read the source file first

2. **Localization Keys**: Check SwiftGen-generated files to verify keys exist
   - ❌ DON'T invent keys (e.g., `L10n.Global.Alerts.timeout` — may not exist)
   - ✅ DO grep `App/Generated/SwiftGen/Strings/` first

3. **New Keys**: When adding new localization keys:
   - Add to **both** `en.lproj/Localizable.strings` and `ar.lproj/Localizable.strings`
   - Run `swiftgen` immediately
   - Verify the key appears in the generated Swift file before using it

4. **Compilation**: Always compile after creating new files
   - Fix ALL errors before considering the task complete
