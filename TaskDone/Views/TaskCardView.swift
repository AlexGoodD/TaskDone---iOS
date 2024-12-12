import SwiftUI

struct TaskCard: View {
    var category: TaskCategory
    @Binding var expandedCategoryId: UUID?

    var isExpanded: Bool {
        expandedCategoryId == category.id
    }

    var body: some View {
        VStack {
            HStack {
                Text(category.name)
                    .font(.title)
                    .foregroundColor(category.color)
                Spacer()
            }
            
            if isExpanded {
                Text("\(category.tasks.filter { $0.isCompleted }.count) / \(category.tasks.count) Tareas Completadas")
                    .font(.subheadline)
                
                ForEach(category.tasks) { task in
                    HStack {
                        Text(task.title)
                            .strikethrough(task.isCompleted, color: .gray)
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(category.color.opacity(0.2)))
        .onTapGesture {
            withAnimation {
                expandedCategoryId = isExpanded ? nil : category.id
            }
        }
    }
}
