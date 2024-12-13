import SwiftUI
import CoreData

struct EditCategoryView: View {
    @Binding var category: TaskCategory
    @State private var tempCategory: TaskCategory
    @State private var hasUnsavedChanges = false
    @State private var showAlert = false
    @State private var newTaskTitle: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TaskViewModel
    
    init(category: Binding<TaskCategory>) {
        self._category = category
        self._tempCategory = State(initialValue: category.wrappedValue)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            categoryNameField
            taskCounter
            Divider().padding(.horizontal)
            taskList
        }
        .padding(.top)
        .toolbar {
            toolbarContent
        }
    }
    
    private var categoryNameField: some View {
        TextField("category-name", text: $tempCategory.name)
            .font(.title)
            .fontWeight(.semibold)
            .padding(.horizontal)
            .onChange(of: tempCategory.name) { _ in
                hasUnsavedChanges = true
            }
    }
    
    private var taskCounter: some View {
        HStack {
            let completedTasks = category.tasks.filter { $0.isCompleted }.count
            let totalTasks = category.tasks.count
            Text(String(format: NSLocalizedString("%d counter-task-of %d counter-tasks", comment: "Task counters"), completedTasks, totalTasks))
                .font(.subheadline)
                .bold()
                .foregroundColor(Color(hex: category.color))
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var taskList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(Array(tempCategory.tasks), id: \.id) { task in
                    taskRow(task: task)
                }
                newTaskRow
            }
        }
    }
    
    private func taskRow(task: Task) -> some View {
        HStack {
            Button(action: {
                viewModel.toggleTaskCompletion(taskId: task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(Color(hex: category.color))
                    .bold()
            }
            .disabled(task.title.isEmpty ?? true) // Deshabilitar si la tarea no tiene texto
            
            let taskTitleBinding = Binding(
                get: { task.title ?? "" },
                set: { newValue in
                    if newValue.isEmpty {
                        viewModel.removeTask(task: task, from: tempCategory)
                    } else {
                        viewModel.updateTaskTitle(task: task, newTitle: newValue)
                    }
                    hasUnsavedChanges = true
                }
            )
            
            TextField("task-add", text: taskTitleBinding)
                .placeholder(when: task.title.isEmpty ?? true) {
                    Text("task-add").foregroundColor(.gray)
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
                addNewTask()
            }) {
                Image(systemName: "square")
                    .foregroundColor(Color(hex: category.color))
                    .bold()
            }
            TextEditor(text: $newTaskTitle)
                .frame(height: 40)
                .onChange(of: newTaskTitle) { newValue in
                    if newValue.contains("\n") {
                        let trimmedTitle = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedTitle.isEmpty {
                            addNewTask(title: trimmedTitle)
                        }
                        newTaskTitle = ""
                    }
                }
                .onSubmit {
                    if !newTaskTitle.isEmpty {
                        addNewTask(title: newTaskTitle)
                        newTaskTitle = ""
                    }
                }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                viewModel.saveCategoryChanges(category: category, tempCategory: tempCategory)
                hasUnsavedChanges = false
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "tray.full")
            }
        }
        return ToolbarItem(placement: .bottomBar) {
            Menu {
                Button(role: .destructive) {
                    viewModel.removeCategory(category.objectID)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("category-delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
        }
    }
    
    private func addNewTask(title: String = "task-add") {
        let newTask = Task(context: viewModel.context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.category = tempCategory
        tempCategory.addToTasks(newTask)
        hasUnsavedChanges = true
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
