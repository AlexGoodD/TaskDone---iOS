import SwiftUI

struct CreateCategoryView: View {
    @State private var categoryName: String = ""
    @State private var categoryColor: Color = .blue
    @State private var tasks: [Task] = []
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: ((TaskCategory) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Nombre de Categoría")) {
                    TextField("Nombre", text: $categoryName)
                }
                
                
                Section(header: Text("Color de Categoría")) {
                    ColorPicker("Selecciona un Color", selection: $categoryColor)
                }
                
                
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
                        tasks.append(Task(title: "Nueva Tarea", isCompleted: false))
                    }) {
                        Text("Agregar Nueva Tarea")
                    }
                }
            }
            .navigationTitle("Crear Categoría")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        if !categoryName.isEmpty {
                            let newCategory = TaskCategory(name: categoryName, color: categoryColor, tasks: tasks)
                            
                            
                            viewModel.addCategory(name: categoryName, color: categoryColor, tasks: tasks)
                            onSave?(newCategory)
                            
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(categoryName.isEmpty) 
                }
            }
        }
    }
}


struct CreateCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCategoryView { newCategory in
            print("Nueva Categoría Creada: \(newCategory)")
        }
        .environmentObject(TaskViewModel()) 
    }
}