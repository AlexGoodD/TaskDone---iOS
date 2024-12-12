import SwiftUI

struct TaskRow: View {
    @State var task: Task
    @ObservedObject var viewModel: TaskViewModel
    var isEditable: Bool = true 
    
    var body: some View {
        HStack {
            if isEditable {
                Button(action: {
                    if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                        viewModel.tasks[index].isCompleted.toggle()
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
            } else {
                Image(systemName: "circle.fill")
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(task.dueDateFormatted)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}