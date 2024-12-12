import Foundation
import CoreData

@objc(TaskCategory)
public class TaskCategory: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var tasks: Set<Task>
}

