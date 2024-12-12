import SwiftUI

struct CreateCategoryView: View {
    @State private var categoryName: String = ""
    @State private var categoryColor: Color = .blue
    @State private var tasks: [LocalTask] = []
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: ((TaskCategory) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nombre de Categoría")) {
                    TextField("Nombre", text: $categoryName)
                }
                
                /*
                Section(header: Text("Color de Categoría")) {
                    ColorPicker("Selecciona un Color", selection: $categoryColor)
                }
                */
                
                Section(header: Text("Tareas")) {
                    ForEach($tasks) { $task in
                        HStack {
                            TextField("Título de Tarea", text: $task.title)
                            Spacer()
                            Button(action: {
                                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                    tasks.remove(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: {
                        tasks.append(LocalTask(title: "Nueva Tarea", isCompleted: false))
                    }) {
                        Text("Agregar Nueva Tarea")
                    }
                }
            }
            .navigationBarTitle("Crear Categoría", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Guardar") {
                saveCategory()
            })
        }
    }
    
    private func saveCategory() {
    
    let newCategory = TaskCategory(context: viewModel.context)
    newCategory.id = UUID()
    newCategory.name = categoryName
    

    
    tasks.forEach { task in
        let newTask = Task(context: viewModel.context)
        newTask.id = task.id
        newTask.title = task.title
        newTask.isCompleted = task.isCompleted
        newTask.category = newCategory 
        newCategory.addToTasks(newTask) 
    }


    
    viewModel.saveContext()
        viewModel.fetchCategories() 

        viewModel.printCategories()
    
    
    onSave?(newCategory)
    
    
    presentationMode.wrappedValue.dismiss()
}
}

struct LocalTask: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}

struct CreateCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = TaskViewModel()
        
        return CreateCategoryView { newCategory in
            print("Nueva Categoría Creada: \(newCategory)")
        }
        .environmentObject(viewModel)
    }
}
