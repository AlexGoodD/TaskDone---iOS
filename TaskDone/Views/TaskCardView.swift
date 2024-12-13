import SwiftUI

struct TaskCard: View {
    var category: TaskCategory
    @Binding var expandedCategoryId: UUID?
    @EnvironmentObject var viewModel: TaskViewModel

    @State private var visibleTaskCount: Int = 0 
    private let animationDuration: Double = 0.3
    private let maxVisibleTasks: Int = 5 

    var isExpanded: Bool {
        viewModel.categories.contains(where: { $0.id == category.id }) && expandedCategoryId == category.id
    }

    var body: some View {
        VStack {
            HStack {
                Text(category.name)
                    .font(isExpanded ? .title : .headline)
                    .bold()
                    .foregroundColor(isExpanded ? Color(hex: category.color).darker(by: 20) : Color(hex: category.color).darker(by: 20).opacity(0.5))
                Spacer()
            }

            if isExpanded {
                VStack(spacing: 10) {
                    HStack {
                        Text("\(category.tasks.filter { $0.isCompleted }.count) of \(category.tasks.count) tasks")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color(hex: category.color).darker(by: 20))
                        Spacer()
                    }
                    .transition(.opacity)

                    ForEach(Array(category.tasks.prefix(maxVisibleTasks)), id: \.id) { task in
                        if visibleTaskCount > 0 {
                            taskRow(for: task)
                                .foregroundColor(Color(hex: category.color).darker(by: 20))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }

                    if category.tasks.count > maxVisibleTasks && visibleTaskCount >= maxVisibleTasks {
                        Text("...")
                            .font(.headline)
                            .foregroundColor(Color(hex: category.color))
                            .transition(.opacity)
                    }
                }
                .onAppear {
                    showTasksSequentially()
                }
                .onDisappear {
                    resetVisibleTasks()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isExpanded ? Color(hex: category.color).opacity(0.3) : Color(hex: category.color).opacity(0.1))
                .shadow(color: Color(hex: category.color).opacity(0.5), radius: 10, x: 0, y: 5)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: animationDuration)) {
                expandedCategoryId = isExpanded ? nil : category.id
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation {
                    // Si la categoría actual está expandida, colapsarla antes de eliminar
                    if expandedCategoryId == category.id {
                        expandedCategoryId = nil
                    }

                    // Eliminar la categoría
                    viewModel.removeCategory(category.objectID)
                }
            } label: {
                Label("category-delete", systemImage: "trash")
            }
        }
    }

    private func taskRow(for task: Task) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleTaskCompletion(taskId: task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(Color(hex: category.color))
                    .bold()
            }
            Text(task.title)
                .strikethrough(task.isCompleted)
            Spacer()
        }
        .opacity(task.isCompleted ? 0.5 : 1.0)
        .padding(.vertical, 5)
    }

    private func showTasksSequentially() {
        visibleTaskCount = 0
        for index in 0..<category.tasks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                visibleTaskCount += 1
            }
        }
    }

    private func resetVisibleTasks() {
        visibleTaskCount = 0
    }
}