import SwiftUI

struct TaskCard: View {
    var category: TaskCategory
    @Binding var expandedCategoryId: UUID?
    @EnvironmentObject var viewModel: TaskViewModel // Referencia al ViewModel

    var isExpanded: Bool {
        expandedCategoryId == category.id
    }

    var body: some View {
        VStack {
            HStack {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(category.color)
                Spacer()
            }
            
            if isExpanded {
                Text("\(category.tasks.filter { $0.isCompleted }.count) / \(category.tasks.count) Tareas Completadas")
                    .font(.subheadline)
                
                ForEach(category.tasks) { task in
                    HStack {
                        Button(action: {
                            viewModel.toggleTaskCompletion(categoryId: category.id, taskId: task.id)
                        }) {
                            Image(systemName: task.isCompleted ? "" : "square")
                                .foregroundColor(.accentColor)
                        }
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                        Spacer()
                        
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(category.color.opacity(0.2)))
        .opacity(isExpanded ? 1.0 : 0.5) // Ajusta la opacidad aquí
        .onTapGesture {
            withAnimation {
                expandedCategoryId = isExpanded ? nil : category.id
            }
        }
    }
}
