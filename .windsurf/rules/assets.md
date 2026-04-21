# Assets Rules

## Colors

- All colors **must** be added to `App/Resources/Colors.xcassets` — never hardcode `UIColor(red:green:blue:alpha:)` or hex values in code
- Use **semantic color names** that describe purpose, not appearance (e.g., `backgroundPrimary`, `accentColor`, `errorAlertBackgroundColor`) — avoid names like `lightPurple` or `grey90` that describe the value
- Every color **must** have both Light and Dark appearance variants in the asset catalog — no excuses
- Reference colors **only** via SwiftGen-generated `Asset.Colors.someColor.color` — `UIColor(named:)` is banned
- Verify contrast ratios meet WCAG 2.1 AA (4.5:1 for normal text, 3:1 for large text)

## Images

- All images **must** be added to `App/Resources/Images.xcassets`
- Use descriptive names that indicate the image's purpose (e.g., `navigationBackButton`, `coursesLogo`, `filledStar`)
- Use **vector PDFs** for all icons and scalable graphics — raster @1x/@2x/@3x only for photos or complex illustrations
- Reference images **only** via SwiftGen-generated `Asset.Images.someName.image` — `UIImage(named:)` is banned

## System Images (SF Symbols)

- **Always** use SFSafeSymbols library for SF Symbol references — `Image(systemSymbol: .ellipsisCircle)` provides compile-time safety
- `Image(systemName: "ellipsis.circle")` (string-based) is **banned** — it can crash at runtime with invalid names
- Verify symbol availability for the app's minimum deployment target before use

## Fonts

- All custom fonts **must** be added to `App/Resources/Fonts/`
- Reference fonts **only** via SwiftGen-generated `FontFamily.*` accessors — `UIFont(name:size:)` with raw string names is banned
- Register custom fonts in the Info.plist `UIAppFonts` key

## Hard Rules

1. **Never** use raw string APIs: `UIImage(named:)`, `UIColor(named:)`, `UIFont(name:size:)` — always use SwiftGen accessors
2. **Always** run `swiftgen` after adding/renaming any asset, color, font, or localization file
3. **Always** provide dark mode variants for colors — "where applicable" is not a loophole
4. **Always** remove unused assets when deleting code that referenced them
