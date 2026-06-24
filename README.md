# Mandarin Drift

Mandarin Drift is an original iOS-first Mandarin learning app built in SwiftUI around daily cards, spaced repetition, search, widgets, pronunciation, wallpaper study mode, streaks, and calm progress tracking.

## Requirements
- macOS with full Xcode installed
- Xcode 16+
- iOS 17+
- `xcodegen` installed locally

## Project Layout
- `App/`: SwiftUI app target
- `Core/`: shared Swift package (`MandarinCore`)
- `Widgets/`: WidgetKit extension
- `Tests/`: unit, UI, and widget tests
- `Docs/`: PRD, UX, privacy, launch docs
- `Backend/`: optional backend adapter notes and starter schema

## Run
1. Install Xcode and select it:
   `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
2. Generate the project:
   `xcodegen generate`
3. Open `MandarinDrift.xcodeproj`
4. Set your team, bundle IDs, and App Group identifier
5. Attach `App/Resources/StoreKit.storekit` to the scheme for local subscription testing
6. Run the `MandarinDrift` scheme on an iPhone simulator with iOS 17+

## Widgets
- The widget target reads `widget-state.json` from the shared App Group.
- Replace `group.com.example.mandarindrift.shared` in:
  - `App/MandarinDrift.entitlements`
  - `Widgets/MandarinDriftWidgets.entitlements`
  - `Core/Services/WidgetStateService.swift`

## Tests
- Unit tests: `MandarinDriftTests`
- UI tests: `MandarinDriftUITests`
- Widget tests: `WidgetTests`

Run in Xcode or with:
`xcodebuild test -scheme MandarinDrift -destination 'platform=iOS Simulator,name=iPhone 16'`

## StoreKit
- Product IDs used:
  - `com.example.mandarindrift.premium.monthly`
  - `com.example.mandarindrift.premium.yearly`
  - `com.example.mandarindrift.premium.lifetime`
- During development, the app currently boots with `MockStoreKitService`.
- Swap to `StoreKitService()` in `App/MandarinDriftApp.swift` for live StoreKit 2 behavior.

## Seed Content
- `App/Resources/SeedContent.json` contains 55 bundled entries.
- Fields include Hanzi, pinyin, English, usage note, tone tip, components, and examples.
- `SeedImporter` validates content at load time.

## Large Dictionary Import
- Supabase is the recommended production backend for the expanded dataset.
- The app imports dictionary content through `ContentUpdateService` and the remote edge function at [`Backend/edge_functions/fetchContentUpdates.ts`](/Users/abrahambelayneh/MandarinDrift/Backend/edge_functions/fetchContentUpdates.ts).
- Configure these Info.plist values via `project.yml` or Xcode build settings:
  - `ChineseDictionaryAPIURL`
  - `ChineseDictionaryAPIFormat` (`json` or `cedict`)
  - `ChineseDictionaryAPIToken` (optional bearer token)
- The JSON response can be either:
  - a raw `[HanziEntry]` array
  - an object with `items: [HanziEntry]` and metadata
- Recommended setup:
  1. Create a Supabase project.
  2. Run [`Backend/supabase_schema.sql`](/Users/abrahambelayneh/MandarinDrift/Backend/supabase_schema.sql).
  3. Load your expanded dictionary into `content_entries`.
  4. Deploy the edge function.
  5. Point `ChineseDictionaryAPIURL` at `/functions/v1/fetchContentUpdates`.
- For `cedict`, the parser accepts standard CC-CEDICT-style lines and maps them into app entries.
- Do not point the app directly at the MDBG CC-CEDICT download page; their page explicitly says automated or scripted access is prohibited. Use your own licensed backend or a separately permitted source.

## Persistence
- Current local-first implementation uses a JSON document store plus repository interfaces.
- `SwiftDataModels/` contains migration-ready model records for a future SwiftData adapter.
- User review progress is kept separate from content import identities, so seed updates remain idempotent.

## Accessibility
- Dynamic Type-friendly SwiftUI layouts
- VoiceOver labels for core card surfaces
- Tone information not conveyed by color alone
- Large tap targets and reduced-motion-safe interactions

## Known Follow-Up Work
- Replace placeholder delete/export actions with full file export flows
- Add richer UI automation assertions once simulator environment is fixed
- Replace app icon placeholder asset
- Wire release builds to `StoreKitService`
- Add production backend adapter if sync is required

## Legal
- Original app concept and implementation
- No copied proprietary assets, screenshots, layouts, copy, code, or datasets from other products
- Any future dictionary expansion should use properly licensed sources with attribution as required
