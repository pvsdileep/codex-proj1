import Foundation
import CoreData

extension TodoTask {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTask> {
        return NSFetchRequest<TodoTask>(entityName: "TodoTask")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var assignee: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var snoozeUntil: Date?

    @NSManaged public var list: ListEntity?
}

extension TodoTask: Identifiable {}
