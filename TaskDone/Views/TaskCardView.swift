import SwiftUI

struct TaskCard: View {
    var category: TaskCategory
    @Binding var expandedCategoryId: UUID?
    @EnvironmentObject var viewModel: TaskViewModel

    @State private var visibleTaskCount: Int = 0 
    private let animationDuration: Double = 0.3
        private let maxVisibleTasks: Int = 5 

    var isExpanded: Bool {
        expandedCategoryId == category.id
    }

    var body: some View {
        VStack {
            
            HStack {
                Text(category.name)
                    .font(isExpanded ? .title : .headline)
                    .bold()
                    .foregroundColor(category.color)
                Spacer()
            }

            
            if isExpanded {
                VStack(spacing: 10) {
                    
                    HStack {
                        Text("\(category.tasks.filter { $0.isCompleted }.count) of \(category.tasks.count) tasks")
                            .font(.subheadline)
                            .foregroundColor(category.color)
                        Spacer()
                    }
                    .transition(.opacity)

                    
                    ForEach(category.tasks.prefix(maxVisibleTasks).indices, id: \.self) { index in
                        if index < visibleTaskCount {
                            taskRow(for: category.tasks[index])
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }

                    
                    if category.tasks.count > maxVisibleTasks && visibleTaskCount >= maxVisibleTasks {
                        Text("...")
                            .font(.headline)
                            .foregroundColor(category.color)
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
        .background(RoundedRectangle(cornerRadius: 12).fill(category.color.opacity(0.2)))
        .opacity(isExpanded ? 1.0 : 0.5)
        .onTapGesture {
            withAnimation(.easeInOut(duration: animationDuration)) {
                expandedCategoryId = isExpanded ? nil : category.id
            }
        }
    }

    
    private func taskRow(for task: Task) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleTaskCompletion(categoryId: category.id, taskId: task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(.accentColor)
            }
            Text(task.title)
                .strikethrough(task.isCompleted)
            Spacer()
        }
        .padding(.vertical, 5)
    }

    
    private func showTasksSequentially() {
        visibleTaskCount = 0
        for index in 0..<category.tasks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    visibleTaskCount += 1
                }
            }
        }
    }

    
    private func resetVisibleTasks() {
        visibleTaskCount = 0
    }
}