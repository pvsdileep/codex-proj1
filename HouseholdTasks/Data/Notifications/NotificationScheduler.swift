import Foundation
import UserNotifications
import CoreData

final class NotificationScheduler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationScheduler()

    func requestAuth() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        let actions = [
            UNNotificationAction(identifier: "COMPLETE", title: "Mark Done", options: []),
            UNNotificationAction(identifier: "SNOOZE_10", title: "Snooze 10m", options: []),
            UNNotificationAction(identifier: "SNOOZE_30", title: "Snooze 30m", options: []),
            UNNotificationAction(identifier: "SNOOZE_60", title: "Snooze 1h", options: [])
        ]
        let category = UNNotificationCategory(identifier: "TASK_REMINDER", actions: actions, intentIdentifiers: [], options: [.customDismissAction])
        center.setNotificationCategories([category])
        center.delegate = self
    }

    func schedule(task: TodoTask) {
        guard let due = task.dueAt else { return }
        let content = UNMutableNotificationContent()
        content.title = task.title ?? "Task"
        content.body = "Due now"
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskID": task.objectID.uriRepresentation().absoluteString]

        let interval = max(5, due.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let id = task.id?.uuidString ?? UUID().uuidString
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    func snooze(task: TodoTask, minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = task.title ?? "Task"
        content.body = "Snoozed"
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskID": task.objectID.uriRepresentation().absoluteString]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(minutes * 60), repeats: false)
        let id = (task.id?.uuidString ?? UUID().uuidString) + ".snooze"
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))

        task.snoozeUntil = Date().addingTimeInterval(Double(minutes * 60))
        try? task.managedObjectContext?.save()
    }

    func cancelNotifications(for task: TodoTask, completion: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        let taskURL = task.objectID.uriRepresentation().absoluteString
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.content.userInfo["taskID"] as? String == taskURL }
                              .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: ids)
            center.getDeliveredNotifications { delivered in
                let deliveredIds = delivered.filter { $0.request.content.userInfo["taskID"] as? String == taskURL }
                                            .map { $0.request.identifier }
                center.removeDeliveredNotifications(withIdentifiers: deliveredIds)
                completion?()
            }
        }
    }

    func scheduleGentleSnoozeIfNeeded(for task: TodoTask) {
        guard let due = task.dueAt, !task.isCompleted else { return }
        let windowEnd = due.addingTimeInterval(2 * 60 * 60) // 2h window
        if Date() < windowEnd {
            snooze(task: task, minutes: 15)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let urlString = response.notification.request.content.userInfo["taskID"] as? String,
              let url = URL(string: urlString),
              let id = PersistenceController.shared.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url),
              let task = try? PersistenceController.shared.container.viewContext.existingObject(with: id) as? TodoTask else { return }

        switch response.actionIdentifier {
        case "COMPLETE":
            task.isCompleted = true
            try? task.managedObjectContext?.save()
        case "SNOOZE_10": snooze(task: task, minutes: 10)
        case "SNOOZE_30": snooze(task: task, minutes: 30)
        case "SNOOZE_60": snooze(task: task, minutes: 60)
        default:
            break
        }
    }
}
