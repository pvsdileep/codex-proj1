import Foundation
import CoreData

@objc(TodoTask)
public class TodoTask: NSManagedObject {}

public enum TaskPriority: Int16, CaseIterable { case low = 0, medium = 1, high = 2 }

extension TodoTask {
    var priorityEnum: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .medium }
        set { priority = newValue.rawValue }
    }
    var isOverdue: Bool { (dueAt ?? .distantFuture) < Date() && !isCompleted }
}
