import SwiftUI
import CoreData

struct CreateCategoryView: View {
    @State private var categoryName: String = ""
    @State private var categoryColor: Color = .blue
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            categoryNameField
            taskCounter
            Divider().padding(.horizontal)
            taskList
        }
        .padding(.top)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ColorPicker("Select Color", selection: $categoryColor)
                    .labelsHidden()
                Button(action: {
                    viewModel.saveCategory(name: categoryName, color: UIColor(categoryColor), tasks: tasks, presentationMode: presentationMode)
                }) {
                    Image(systemName: "tray.full")
                        .foregroundColor(categoryColor)
                }
            }
        }
    }

    private var categoryNameField: some View {
        TextField("category-name", text: $categoryName)
            .font(.title)
            .foregroundColor(categoryColor)
            .fontWeight(.semibold)
            .padding(.horizontal)
    }

    private var taskCounter: some View {
        HStack {
            let completedTasks = tasks.filter { $0.isCompleted }.count
            let totalTasks = tasks.count
            Text(String(format: NSLocalizedString("%d counter-task-of %d counter-tasks", comment: "Task counters"), completedTasks, totalTasks))
                .font(.subheadline)
                .bold()
                .foregroundColor(categoryColor)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var taskList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(tasks) { task in
                    taskRow(task: task)
                }
                newTaskRow
            }
        }
    }

    private func taskRow(task: Task) -> some View {
        HStack {
            Button(action: {
                task.isCompleted.toggle()
                viewModel.saveContext()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(categoryColor)
                    .bold()
            }
            .disabled(task.title.isEmpty)
            
            let taskTitleBinding = Binding(
                get: { task.title ?? "" },
                set: { newValue in
                    if newValue.isEmpty {
                        if let category = task.category {
                            viewModel.removeTask(task: task, from: category)
                        }
                    } else {
                        viewModel.updateTaskTitle(task: task, newTitle: newValue)
                    }
                }
            )
            
            TextField("task-add", text: taskTitleBinding)
                .foregroundColor(categoryColor)
                .placeholder(when: task.title.isEmpty ?? true) {
                    Text("task-add").foregroundColor(categoryColor)
                }
                .strikethrough(task.isCompleted)
            Spacer()
        }
        .opacity(task.isCompleted ? 0.5 : 1.0)
        .padding(.horizontal)
    }

    private var newTaskRow: some View {
        HStack {
            Button(action: {
                viewModel.addNewTask(title: newTaskTitle, to: &tasks)
                newTaskTitle = ""
            }) {
                Image(systemName: "square")
                    .foregroundColor(categoryColor)
                    .bold()
            }
            TextEditor(text: $newTaskTitle)
                .frame(height: 40)
                .foregroundColor(categoryColor)
                .onChange(of: newTaskTitle) { newValue in
                    if newValue.contains("\n") {
                        let trimmedTitle = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedTitle.isEmpty {
                            viewModel.addNewTask(title: trimmedTitle, to: &tasks)
                        }
                        newTaskTitle = ""
                    }
                }
                .onSubmit {
                    if !newTaskTitle.isEmpty {
                        viewModel.addNewTask(title: newTaskTitle, to: &tasks)
                        newTaskTitle = ""
                    }
                }
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct CreateCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = TaskViewModel(context: context)
        
        return CreateCategoryView()
            .environmentObject(viewModel)
    }
}
