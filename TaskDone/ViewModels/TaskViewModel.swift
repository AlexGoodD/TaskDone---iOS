import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var categories: [TaskCategory] = [
        TaskCategory(name: "Trabajo", color: .blue, tasks: [
            Task(title: "Terminar el reporte", isCompleted: false),
            Task(title: "Revisar correos", isCompleted: true)
        ]),
        TaskCategory(name: "Casa", color: .green, tasks: [
            Task(title: "Lavar la ropa", isCompleted: false),
            Task(title: "Comprar comida", isCompleted: false)
        ])
    ]
    @Published var isEditing: Bool = false
    @Published var expandedCategoryId: UUID? = nil 

    func addCategory() {
        categories.append(TaskCategory(name: "Nueva Categoría", color: .gray, tasks: []))
    }

    func addTask(to categoryId: UUID) {
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[index].tasks.append(Task(title: "Nueva Tarea", isCompleted: false))
        }
    }
}
