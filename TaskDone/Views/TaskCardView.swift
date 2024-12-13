import SwiftUI
import CoreData

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
            headerView

            if isExpanded {
                expandedView
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
    }

    private var headerView: some View {
        HStack {
            Text(category.name)
                .font(isExpanded ? .title : .headline)
                .bold()
                .foregroundColor(isExpanded ? Color(hex: category.color).darker(by: 20) : Color(hex: category.color).darker(by: 20).opacity(0.5))
            Spacer()
        }
    }


    private var topFiveTasks: [Task] {
    Array(sortedTasks.prefix(5))
}

private var expandedView: some View {
    VStack(spacing: 10) {
        HStack {
            Text("\(category.tasks.filter { $0.isCompleted }.count) of \(category.tasks.count) tasks")
                .font(.subheadline)
                .bold()
                .foregroundColor(Color(hex: category.color).darker(by: 20))
            Spacer()
        }
        .transition(.opacity)

        
        ForEach(topFiveTasks, id: \.id) { task in
            taskRow(for: task)
                .foregroundColor(Color(hex: category.color).darker(by: 20))
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
        category.tasks.sorted {
            if $0.isCompleted == $1.isCompleted {
                return $0.creationDate < $1.creationDate
            }
            return !$0.isCompleted && $1.isCompleted
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
}