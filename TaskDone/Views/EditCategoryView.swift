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
            TextField("Nombre de Categoría", text: $tempCategory.name)
                .font(.title)
                .foregroundColor(Color(hex: category.color))
                .padding(.horizontal)
                .onChange(of: tempCategory.name) { _ in
                    hasUnsavedChanges = true
                }
            
            HStack {
                Text("\(category.tasks.filter { $0.isCompleted }.count) of \(category.tasks.count) tasks")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: category.color))
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(tempCategory.tasks), id: \.id) { task in
                        HStack {
                            Button(action: {
                                viewModel.toggleTaskCompletion(taskId: task.id)
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                                    .foregroundColor(Color(hex: category.color))
                                    .bold()
                            }
                            TextField("Título de Tarea", text: Binding(
                                get: { task.title ?? "" },
                                set: { newValue in
                                    if newValue.isEmpty {
                                        viewModel.removeTask(task: task, from: tempCategory)
                                    } else {
                                        viewModel.updateTaskTitle(task: task, newTitle: newValue)
                                    }
                                    hasUnsavedChanges = true
                                }
                            ))
                            .strikethrough(task.isCompleted)
                            Spacer()
                        }
                        .opacity(task.isCompleted ? 0.5 : 1.0)
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Button(action: {
                            addNewTask()
                        }) {
                            Image(systemName: "square")
                                .foregroundColor(Color(hex: category.color))
                                .bold()
                        }
                        TextField("Add task", text: $newTaskTitle)
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.saveCategoryChanges(category: category, tempCategory: tempCategory)
                    hasUnsavedChanges = false
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "tray.full")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Cambios sin guardar"),
                message: Text("Tienes cambios sin guardar. ¿Estás seguro de que quieres salir sin guardar?"),
                primaryButton: .destructive(Text("Salir")) {
                    hasUnsavedChanges = false
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
        .onDisappear {
            if hasUnsavedChanges {
                showAlert = true
            }
        }
    }
    
    private func addNewTask(title: String = "Add task") {
        let newTask = Task(context: viewModel.context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.category = tempCategory
        tempCategory.addToTasks(newTask)
        hasUnsavedChanges = true
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        
        let exampleContext = PersistenceController.preview.container.viewContext
        
        
        guard let categoryEntity = NSEntityDescription.entity(forEntityName: "TaskCategory", in: exampleContext) else {
            fatalError("No se pudo encontrar la entidad 'TaskCategory' en el modelo de datos.")
        }
        
        
        guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: exampleContext) else {
            fatalError("No se pudo encontrar la entidad 'Task' en el modelo de datos.")
        }
        
        let exampleCategory = TaskCategory(entity: categoryEntity, insertInto: exampleContext)
        exampleCategory.id = UUID()
        exampleCategory.name = "Ejemplo Categoría"
        
        let task1 = Task(entity: taskEntity, insertInto: exampleContext)
        task1.id = UUID()
        task1.title = "Ejemplo Tarea 1"
        task1.isCompleted = false
        task1.category = exampleCategory
        
        let task2 = Task(entity: taskEntity, insertInto: exampleContext)
        task2.id = UUID()
        task2.title = "Ejemplo Tarea 2"
        task2.isCompleted = true
        task2.category = exampleCategory
        
        exampleCategory.addToTasks(task1)
        exampleCategory.addToTasks(task2)
        
        let viewModel = TaskViewModel()
        viewModel.categories = [exampleCategory]
        
        return NavigationView {
            EditCategoryView(category: .constant(exampleCategory))
                .environment(\.managedObjectContext, exampleContext)
                .environmentObject(viewModel)
        }
    }
}