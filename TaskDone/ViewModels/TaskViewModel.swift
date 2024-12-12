import Foundation

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [] // Lista de tareas
    
    // Tareas próximas (aún no vencidas y no completadas)
    var upcomingTasks: [Task] {
        tasks.filter { !$0.isCompleted && $0.dueDate > Date() }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    // Tareas vencidas (no completadas y fecha de vencimiento pasada)
    var overdueTasks: [Task] {
        tasks.filter { !$0.isCompleted && $0.dueDate <= Date() }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    // Tareas completadas
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    // Método para agregar una nueva tarea
    func addTask(title: String, dueDate: Date) {
        tasks.append(Task(title: title, dueDate: dueDate))
    }
    
    // Método para eliminar tareas vencidas y completadas después de 7 días
    func cleanOldTasks() {
        let thresholdDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        tasks.removeAll { $0.dueDate < thresholdDate && ($0.isCompleted || $0.dueDate <= Date()) }
    }
}