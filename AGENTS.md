# Repository Guidelines

## Project Structure
- `HouseholdTasks/`: iOS app (SwiftUI + Core Data).
  - `App/`: app entry and navigation (`HouseholdTasksApp`, `RootView`).
  - `Features/`: feature views by area (`MyDay`, `Shared`, `Edit`, `Common`).
  - `Data/`: persistence, notifications, sharing; model at `HouseholdTasks.xcdatamodeld`.
  - `Models/`: Core Data generated files; project at `HouseholdTasks.xcodeproj`.
- `HouseholdTasksWidget/`: WidgetKit extension (`TasksWidget*`).
- `bin/`: tooling (`codex` wrapper).  `Makefile`: `codex` helper target.

## Build, Run, Test
- Xcode open: `HouseholdTasks/HouseholdTasks.xcodeproj`.
- Scheme: select `HouseholdTasks` to run the app; select `TasksWidget` to debug the widget extension.
- Destination: choose an iOS Simulator (e.g., iPhone 15) or a connected device (fix signing if using a device).
- Build/Run: Product → Build (Cmd-B), Run (Cmd-R). Clean build folder with Shift-Cmd-K if build settings change.
- Test: none committed yet. When tests exist, Product → Test (Cmd-U). Place tests under `HouseholdTasksTests/` and name `<TypeName>Tests`.
- CLI build: `xcodebuild -project HouseholdTasks/HouseholdTasks.xcodeproj -scheme HouseholdTasks -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build`.
- CLI test: `xcodebuild test -project HouseholdTasks/HouseholdTasks.xcodeproj -scheme HouseholdTasks -destination 'platform=iOS Simulator,name=iPhone 15'`.
- Tooling: `make codex ARGS="..."` runs the repo’s Codex CLI wrapper (`./bin/codex`).

## Coding Style & Naming
- Follow Swift API Design Guidelines; Swift 5 / SwiftUI idioms.
- Indentation: 4 spaces; prefer 100–120 column soft wrap.
- Types/protocols: UpperCamelCase. Functions/vars/cases: lowerCamelCase. Files match primary type (e.g., `MyDayView.swift`).
- Organize UI in `Features/<Area>/`, shared UI in `Features/Common/`, data-layer in `Data/<Area>/`.

## Testing Guidelines
- Use XCTest; name tests `<TypeName>Tests` and mirror source paths under `HouseholdTasksTests/`.
- Prioritize coverage for persistence, deep links (`onOpenURL`), and widget timeline generation.
- Use SwiftUI previews for view contracts; keep logic testable outside views when possible.

## Commit & PR Guidelines
- Commits: prefer Conventional Commits (`feat:`, `fix:`, `chore:`); concise subjects (≤72 chars).
- PRs: include summary, linked issues, screenshots for UI, repro steps, target scheme, and simulator device/OS.
- Update docs when changing structure, entitlements, Core Data model, or App Group IDs.

## Security & Configuration
- Signing: Debug uses local signing; adjust bundle identifiers as needed.
- Entitlements: keep `HouseholdTasks.Local.entitlements` in sync with `HouseholdTasks.entitlements`.
- App Groups: widget is intended to read a shared store—configure a shared App Group and use the same identifier for app and widget.
