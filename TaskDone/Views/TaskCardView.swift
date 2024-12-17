import CoreData
import SwiftUI

struct TaskCard: View {
    var category: TaskCategory
    @Binding var expandedCategoryId: UUID?
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var visibleTaskCount: Int = 0
    @State private var visibleTasks: [Task] = []
    private let animationDuration: Double = 0.3
    private let maxVisibleTasks: Int = 5

    var isExpanded: Bool {
        expandedCategoryId == category.id
    }

    var body: some View {
        VStack {
            headerView

            if isExpanded {
                expandedView
                    .onAppear {
                        prepareVisibleTasks()
                        showTasksSequentially()
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isExpanded
                        ? Color(hex: category.color).opacity(0.3)
                        : Color(hex: category.color).opacity(0.1)
                )
                .shadow(color: Color(hex: category.color).opacity(0.5), radius: 10, x: 0, y: 5)
        )
        .onTapGesture {
            if isExpanded {
                if visibleTaskCount == 0 {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        expandedCategoryId = nil
                    }
                } else {
                    hideTasksSequentially {
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                expandedCategoryId = nil
                            }
                        }
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    expandedCategoryId = category.id
                    visibleTaskCount = 0
                }
            }
        }
        .onAppear {
            if !isExpanded {
                prepareVisibleTasks()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text(category.name)
                .font(isExpanded ? .title : .headline)
                .bold()
                .foregroundColor(
                    isExpanded
                        ? (colorScheme == .dark
                            ? Color(hex: category.color)
                            : Color(hex: category.color).darker(by: 20))
                        : (colorScheme == .dark
                            ? Color(hex: category.color).opacity(0.5)
                            : Color(hex: category.color).darker(by: 20).opacity(0.5)))
            Spacer()
        }
    }

    private var expandedView: some View {
        VStack(spacing: 10) {
            HStack {
                Text(
                    "\(category.tasks.filter { $0.isCompleted }.count) of \(category.tasks.count) tasks"
                )
                .font(.subheadline)
                .bold()
                .foregroundColor(
                    isExpanded
                        ? (colorScheme == .dark
                            ? Color(hex: category.color)
                            : Color(hex: category.color).darker(by: 20))
                        : (colorScheme == .dark
                            ? Color(hex: category.color).opacity(0.5)
                            : Color(hex: category.color).darker(by: 20).opacity(0.5)))
                Spacer()
            }
            .transition(.opacity)

            ForEach(visibleTasks.prefix(visibleTaskCount), id: \.id) { task in
                taskRow(for: task)
                    .foregroundColor(
                        isExpanded
                            ? (colorScheme == .dark
                                ? Color(hex: category.color)
                                : Color(hex: category.color).darker(by: 20))
                            : (colorScheme == .dark
                                ? Color(hex: category.color).opacity(0.5)
                                : Color(hex: category.color).darker(by: 20).opacity(0.5))
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if category.tasks.count > 5 {
                Text("...")
                    .font(.headline)
                    .foregroundColor(Color(hex: category.color))
                    .transition(.opacity)
            }
        }
    }

    private var sortedTasks: [Task] {
        category.tasks.sorted { $0.creationDate < $1.creationDate }
    }

    private func taskRow(for task: Task) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleTaskCompletion(taskId: task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(
                        isExpanded
                            ? (colorScheme == .dark ? Color(hex: category.color)
                                : Color(hex: category.color).darker(by: 20))
                            : (colorScheme == .dark
                                ? Color(hex: category.color).opacity(0.5)
                                : Color(hex: category.color).darker(by: 20).opacity(0.5))
                    )
                    .bold()
            }
            Text(task.title)
                .strikethrough(task.isCompleted)
            Spacer()
        }
        .opacity(task.isCompleted ? 0.5 : 1.0)
        .padding(.vertical, 5)
    }

    private func prepareVisibleTasks() {
        visibleTasks = Array(sortedTasks.prefix(maxVisibleTasks))
        visibleTaskCount = 0 // Ensure visibleTaskCount is reset before showing tasks
    }

    private func showTasksSequentially() {
        visibleTaskCount = 0
        let initialDelay = animationDuration // Retraso inicial igual a la duración de la animación de expansión
        for index in 0..<visibleTasks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay + Double(index) * 0.2) {
                withAnimation {
                    visibleTaskCount = index + 1
                }
            }
        }
    }

    private func hideTasksSequentially(completion: @escaping () -> Void) {
        if visibleTaskCount == 0 {
            completion()
            return
        }
        for index in (0..<visibleTaskCount).reversed() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(visibleTaskCount - index - 1) * 0.2) {
                withAnimation {
                    visibleTaskCount = index
                    if index == 0 {
                        completion()
                    }
                }
            }
        }
    }
}

struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = TaskViewModel(context: context)
        
        // Crear una categoría de ejemplo
        let categoryEntity = NSEntityDescription.entity(forEntityName: "TaskCategory", in: context)!
        let exampleCategory = TaskCategory(entity: categoryEntity, insertInto: context)
        exampleCategory.id = UUID()
        exampleCategory.name = "Ejemplo Categoría"
        exampleCategory.color = "#FF5733"
        
        // Crear algunas tareas de ejemplo
        let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
        for i in 1...5 {
            let task = Task(entity: taskEntity, insertInto: context)
            task.id = UUID()
            task.title = "Tarea \(i)"
            task.isCompleted = false
            task.creationDate = Date()
            task.category = exampleCategory
            exampleCategory.addToTasks(task)
        }
        
        return TaskCard(category: exampleCategory, expandedCategoryId: .constant(nil))
            .environmentObject(viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}