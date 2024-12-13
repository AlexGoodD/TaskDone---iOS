import Foundation
import CoreData

@objc(TaskCategory)
public class TaskCategory: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var tasks: Set<Task>
    @NSManaged public var isHidden: Bool
    

}

