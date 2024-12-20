import SwiftUI
import CoreData

struct EditCategoryView: View {
    @Binding var category: TaskCategory
    @State private var tempCategory: TaskCategory
    @State private var categoryColor: Color {
        didSet {
            tempCategory.color = categoryColor.toUIColor().toHexString()
        }
    }
    @State private var showAlert = false
    @State private var newTaskTitle: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var isClose = false
    
    init(category: Binding<TaskCategory>) {
        self._category = category
        self._tempCategory = State(initialValue: category.wrappedValue)
        self._categoryColor = State(initialValue: Color(hex: category.wrappedValue.color))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            categoryNameField
            taskCounter
            Divider().padding(.horizontal)
            taskList
            
                .onChange(of: viewModel.categories) { categories in
                   if !categories.contains(where: { $0.id == category.id }) {
                        isClose = true
                    }
                }
        }
        .padding(.top)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ColorPicker("Select Color", selection: $categoryColor)
                    .labelsHidden()
                    .onChange(of: categoryColor){ newValue in
                        tempCategory.color = newValue.toUIColor().toHexString()
                    }
            }
        }
        .background(
            NavigationLink(destination: CreateCategoryView(), isActive: $isClose) {
                EmptyView()
            }
        )
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: leadingNavigationBarItem)
    }
    
    @ViewBuilder
    private var leadingNavigationBarItem: some View {
        if UIDevice.current.userInterfaceIdiom != .pad {
            Button(action: {
                    presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(categoryColor)
            }
        }
    }
    
    private var categoryNameField: some View {
        TextField("category-name", text: $tempCategory.name)
            .font(.title)
            .foregroundColor(categoryColor)
            .fontWeight(.semibold)
            .padding(.horizontal)
    }
    
    private var taskCounter: some View {
        HStack {
            let completedTasks = category.tasks.filter { $0.isCompleted }.count
            let totalTasks = category.tasks.count
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
                ForEach(tempCategory.tasksArray, id: \.id) { task in
                    taskRow(task: task)
                }
                newTaskRow
            }
        }
    }
    
    private func taskRow(task: Task) -> some View {
        HStack {
            Button(action: {
                if !task.title.isEmpty && task.title != "task-add" {
                    viewModel.toggleTaskCompletion(taskId: task.id)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                    .foregroundColor(categoryColor)
                    .bold()
            }
            .disabled(task.title.isEmpty || task.title == "task-add")
            
            let taskTitleBinding = Binding(
                get: { task.title },
                set: { newValue in
                    if newValue.isEmpty {
                        viewModel.removeTask(task: task, from: tempCategory)
                    } else {
                        viewModel.updateTaskTitle(task: task, newTitle: newValue)
                    }
                }
            )
            
            TextField("task-add", text: taskTitleBinding)
                .foregroundColor(categoryColor)
                .placeholder(when: task.title.isEmpty) {
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
                let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedTitle.isEmpty {
                    addNewTask(title: trimmedTitle)
                    newTaskTitle = ""
                }
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
                    addNewTask(title: newValue.trimmingCharacters(in: .whitespacesAndNewlines))
                    newTaskTitle = ""
                    }
                }
                .onSubmit {
                    addNewTask(title: newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                    newTaskTitle = ""
                }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func addNewTask(title: String) {
        let newTask = Task(context: viewModel.context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.creationDate = Date() // Fecha de creación
        newTask.category = tempCategory
        tempCategory.addToTasks(newTask)
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

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = TaskViewModel(context: context)
        
        // Crear una categoría de ejemplo
        let categoryEntity = NSEntityDescription.entity(forEntityName: "TaskCategory", in: context)!
        var exampleCategory = TaskCategory(entity: categoryEntity, insertInto: context)
        exampleCategory.id = UUID()
        exampleCategory.name = "Ejemplo Categoría"
        exampleCategory.color = "#FF5733"
        
        // Crear un Binding para la categoría de ejemplo
        let categoryBinding = Binding<TaskCategory>(
            get: { exampleCategory },
            set: { exampleCategory = $0 }
        )
        
        return EditCategoryView(category: categoryBinding)
            .environmentObject(viewModel)
    }
}
