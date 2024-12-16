import SwiftUI
import CoreData

class TaskViewModel: ObservableObject {
    @Published var categories: [TaskCategory] = []
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchCategories()
    }
    
    func fetchCategories() {
        let request = NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
        request.predicate = NSPredicate(format: "isHidden == NO")
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func addCategory(name: String, color: String) {
    guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        print("Error: El nombre de la categoría no puede estar vacío.")
        return
    }
    guard let entity = NSEntityDescription.entity(forEntityName: "TaskCategory", in: context) else {
        print("Error: No se pudo encontrar la entidad 'TaskCategory' en el contexto.")
        return
    }
    let newCategory = TaskCategory(entity: entity, insertInto: context)
    newCategory.id = UUID()
    newCategory.name = name
    newCategory.color = color
    newCategory.isHidden = false
    saveContext()
    fetchCategories()
}
    
    func hideCategory(_ categoryID: NSManagedObjectID) {
        do {
            if let category = try context.existingObject(with: categoryID) as? TaskCategory {
                category.isHidden = true
                saveContext()
                fetchCategories()
            }
        } catch {
            print("Error al intentar ocultar la categoría: \(error)")
        }
    }
    
    func addTask(to categoryId: UUID) {
        guard let category = categories.first(where: { $0.id == categoryId }) else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            print("Error: No se pudo encontrar la entidad 'Task' en el contexto.")
            return
        }
        let newTask = Task(entity: entity, insertInto: context)
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
    
    func updateTaskTitle(task: Task, newTitle: String) {
        task.title = newTitle
        saveContext()
    }
    
    func removeTask(task: Task, from category: TaskCategory) {
        category.removeFromTasks(task)
        saveContext()
    }
    
    func addNewTask(to category: TaskCategory) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            print("Error: No se pudo encontrar la entidad 'Task' en el contexto.")
            return
        }
        let newTask = Task(entity: entity, insertInto: context)
        newTask.id = UUID()
        newTask.title = "Nueva Tarea"
        newTask.isCompleted = false
        newTask.creationDate = Date() // Fecha de creación
        category.addToTasks(newTask)
        saveContext()
    }
    
    func saveCategoryChanges(category: TaskCategory, tempCategory: TaskCategory) {
        category.name = tempCategory.name
        category.tasks = tempCategory.tasks
        category.color = tempCategory.color
        saveContext()
        fetchCategories()
    }
    
    func duplicateCategory(categoryId: UUID) {
    guard let originalCategory = categories.first(where: { $0.id == categoryId }) else {
        print("Error: No se pudo encontrar la categoría original.")
        return
    }
    
    guard let entity = NSEntityDescription.entity(forEntityName: "TaskCategory", in: context) else {
        print("Error: No se pudo encontrar la entidad 'TaskCategory' en el contexto.")
        return
    }
    
    let newCategory = TaskCategory(entity: entity, insertInto: context)
    newCategory.id = UUID()
    let copySuffix = NSLocalizedString("category-copy", comment: "Copia")
    newCategory.name = originalCategory.name + " (\(copySuffix))"
    newCategory.color = originalCategory.color
    newCategory.isHidden = originalCategory.isHidden
    
    for task in originalCategory.tasksArray {
        guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            print("Error: No se pudo encontrar la entidad 'Task' en el contexto.")
            return
        }
        
        let newTask = Task(entity: taskEntity, insertInto: context)
        newTask.id = UUID()
        newTask.title = task.title
        newTask.isCompleted = task.isCompleted
        newTask.creationDate = task.creationDate
        newTask.category = newCategory
        
        newCategory.addToTasks(newTask)
    }
    
    saveContext()
    fetchCategories()
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
        return set.sorted { $0.creationDate < $1.creationDate }
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