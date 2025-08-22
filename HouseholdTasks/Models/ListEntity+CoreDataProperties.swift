import Foundation
import CoreData

extension ListEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListEntity> {
        return NSFetchRequest<ListEntity>(entityName: "ListEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isShared: Bool

    @NSManaged public var tasks: NSSet?
}

extension ListEntity: Identifiable {}

// MARK: Generated accessors for tasks
extension ListEntity {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TodoTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TodoTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}
