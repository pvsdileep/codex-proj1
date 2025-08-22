# HouseholdTasks (iOS)

A SwiftUI + Core Data + CloudKit starter for a household-focused tasks app with two sections: My Day (personal) and Shared (with one partner via CloudKit sharing). Includes local notifications with snooze actions.

## Features in this starter
- SwiftUI tabs: My Day and Shared
- Core Data model (`TodoTask`, `ListEntity`) with CloudKit sync
- CloudKit sharing UI for the shared list
- Local notifications with in-notification actions for Complete and Snooze

## Open in Xcode

Option A — XcodeGen (recommended):
1. Ensure XcodeGen is installed (`brew install xcodegen`).
2. In Terminal, `cd` to this folder and run: `xcodegen generate`.
3. Open `HouseholdTasks.xcodeproj` in Xcode.

Option B — Create an Xcode project manually:
1. In Xcode, File → New → Project… → iOS App.
2. Product Name: HouseholdTasks, Interface: SwiftUI, Language: Swift.
3. Check “Use Core Data”.
4. After project creation, drag the entire `HouseholdTasks` folder into your Xcode project (Copy items if needed).
5. Remove Xcode’s default Core Data model/classes and point the target to use `HouseholdTasks/HouseholdTasks.xcdatamodeld`.

## Capabilities
- Enable iCloud → CloudKit.
- Set the container to `iCloud.com.yourcompany.householdtasks` (to match `PersistenceController`).
- (Optional) Background Modes → Background fetch.

## First run
- On first launch, the app requests Notification permission.
- Create tasks in My Day. Use Share List in Shared tab to invite your partner.

## Notes
- Replace bundle ID and iCloud container with your own before shipping.
- This is a starter scaffold; expand UI/UX and error handling as needed.
