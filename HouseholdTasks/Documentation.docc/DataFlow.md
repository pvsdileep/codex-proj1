# Data Flow

This page shows the high-level data flow for HouseholdTasks across creation/editing, in-list actions, notifications, CloudKit syncing, and the widget deep-link.

## Diagram

![](Assets/data-flow.svg)

> Note: If the image does not appear in the Rendered view, use the ASCII diagram below.

## ASCII Diagram (fallback)

```
  [User]
    |                          (Create/Edit)
    v
 [TaskEditView] --Save--> (Core Data)
        |                    |
        | cancel existing    | auto-merge changes
        v                    v
 (NotificationScheduler)  (viewContext) --> SwiftUI UI updates
        |
        v
 (UNUserNotificationCenter) --(at due)--> [Delivered Notification]
        |                                         |
        +-- COMPLETE / SNOOZE_* actions ----------+
                                                  v
                                     (NotificationScheduler delegate)
                                                  |
                                                  v
                                              (Core Data)

  [User] --(list actions)--> [TaskRow]
        |           |                |
        |           +-- complete/priority/assignee -> (Core Data)
        |           +-- move/snooze -> update dueAt -> (Core Data)
        |                                   |
        |                                   +-- reschedule -> (NotificationScheduler) -> (UN)
        v
    [MyDayView] -- fetch(!completed & due<=EOD) --> (Core Data)
        |-- group (Overdue/Morning/Afternoon/Evening) --> [TaskRow]

  [SharedView] -- fetch(list.isShared==YES & !completed) --> (Core Data)
        |-- Share List --> (UICloudSharingController) --> (NSPersistentCloudKitContainer.share)

  (Core Data) <--> (NSPersistentCloudKitContainer) <--> (CloudKit) <--> [Other Devices]

  [WidgetKit Provider] -> [TasksWidgetEntryView] -- widgetURL --> [RootView onOpenURL] -> [MyDayView]
```
