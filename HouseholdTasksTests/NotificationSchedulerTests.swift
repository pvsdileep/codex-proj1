import XCTest
@testable import HouseholdTasks

final class NotificationSchedulerTests: XCTestCase {
    func testCancelNotificationsDoesNotCrash() {
        let context = PersistenceController.shared.container.viewContext
        let task = TodoTask(context: context)
        task.id = UUID()
        NotificationScheduler.shared.cancelNotifications(for: task)
    }
}
