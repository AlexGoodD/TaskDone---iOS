import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var categories: [TaskCategory] = [
        
    ]
    @Published var isEditing: Bool = false
    @Published var expandedCategoryId: UUID? = nil

    func addCategory(name: String, color: Color, tasks: [Task]) {
        let newCategory = TaskCategory(name: name, color: color, tasks: tasks)
        categories.append(newCategory)
    }

    func addTask(to categoryId: UUID) {
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[index].tasks.append(Task(title: "Nueva Tarea", isCompleted: false))
        }
    }
    
    func toggleTaskCompletion(categoryId: UUID, taskId: UUID) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }),
           let taskIndex = categories[categoryIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            categories[categoryIndex].tasks[taskIndex].isCompleted.toggle()
        }
    }
    
    func editCategory(categoryId: UUID, newName: String?, newColor: Color?) {
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            if let newName = newName {
                categories[index].name = newName
            }
            if let newColor = newColor {
                categories[index].color = newColor
            }
        }
    }

    func deleteCategory(categoryId: UUID) {
        categories.removeAll(where: { $0.id == categoryId })
    }

    func collapseAllCategories() {
    expandedCategoryId = nil
}
}