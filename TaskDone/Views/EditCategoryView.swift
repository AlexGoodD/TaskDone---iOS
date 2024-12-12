import SwiftUI

struct EditCategoryView: View {
    @Binding var category: TaskCategory
    
    var body: some View {
        Form {
            Section(header: Text("Nombre de Categoría")) {
                TextField("Nombre", text: $category.name)
            }
            
            Section(header: Text("Color de Categoría")) {
                ColorPicker("Color", selection: $category.color)
            }
            
            Section(header: Text("Tareas")) {
                ForEach($category.tasks) { $task in
                    HStack {
                        TextField("Título", text: $task.title)
                        Spacer()
                        Button(action: {
                            if let index = category.tasks.firstIndex(where: { $0.id == task.id }) {
                                category.tasks.remove(at: index)
                            }                        }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                    }
                }
                
                Button(action: {
                    category.tasks.append(Task(title: "Nueva Tarea", isCompleted: false))
                }) {
                    Text("Agregar Nueva Tarea")
                }
            }
        }
        .navigationTitle("Editar Categoría")
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        
        let exampleCategory = TaskCategory(
            name: "Trabajo",
            color: .blue,
            tasks: [
                Task(title: "Terminar reporte", isCompleted: false),
                Task(title: "Revisar correos", isCompleted: true),
                Task(title: "Planificar reunión", isCompleted: false)
            ]
        )
        
        
        StatefulPreviewWrapper(exampleCategory) { bindingCategory in
            EditCategoryView(category: bindingCategory)
        }
    }
}


struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> AnyView
    
    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> some View) {
        self._value = State(initialValue: initialValue)
        self.content = { AnyView(content($0)) }
    }
    
    var body: some View {
        content($value)
    }
}
