import SwiftUI
import CoreData

class TaskViewModel: ObservableObject {
    @Published var categories: [TaskCategory] = []
    let context = PersistenceController.shared.container.viewContext

    init() {
        fetchCategories()
    }

    func fetchCategories() {
        let request = NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }

    func addCategory(name: String) {
        let newCategory = TaskCategory(context: context)
        newCategory.id = UUID()
        newCategory.name = name
        saveContext()
        fetchCategories() 
    }

    func addTask(to categoryId: UUID, title: String) {
        guard let category = categories.first(where: { $0.id == categoryId }) else { return }
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.category = category
        category.addToTasks(newTask) 
        saveContext()
        fetchCategories()
    }

    func toggleTaskCompletion(taskId: UUID) {
        
        for category in categories {
            if let task = category.tasksArray.first(where: { $0.id == taskId }) {
                task.isCompleted.toggle()
                saveContext()
                fetchCategories()
                break
            }
        }
    }
    
    func printCategories() {
        do {
            for category in categories {
                print("Categoría: \(category.name ?? "Sin Nombre")")
                if let tasks = category.tasks as? Set<Task> {
                    for task in tasks {
                        print("  - Tarea: \(task.title ?? "Sin Título") (Completada: \(task.isCompleted))")
                    }
                }
            }
        } catch {
            print("Error fetching categories: \(error)")
        }
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

extension TaskCategory {
    
    var tasksArray: [Task] {
        let set = tasks as? Set<Task> ?? []
        return set.sorted { $0.title < $1.title }
    }
}


extension TaskCategory {
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}
