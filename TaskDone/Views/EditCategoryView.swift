import SwiftUI

struct EditCategoryView: View {
    @Binding var category: TaskCategory
    @State private var tempCategory: TaskCategory
    @State private var hasUnsavedChanges = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode

    init(category: Binding<TaskCategory>) {
        self._category = category
        self._tempCategory = State(initialValue: category.wrappedValue)
    }

    var body: some View {
        Form {
            Section(header: Text("Nombre de Categoría")) {
                TextField("Nombre", text: $tempCategory.name)
                    .onChange(of: tempCategory.name) { _ in
                        hasUnsavedChanges = true
                    }
            }

            Section(header: Text("Color de Categoría")) {
                ColorPicker("Color", selection: $tempCategory.color)
                    .onChange(of: tempCategory.color) { _ in
                        hasUnsavedChanges = true
                    }
            }

            Section(header: Text("Tareas")) {
                ForEach($tempCategory.tasks) { $task in
                    HStack {
                        TextField("Título", text: $task.title)
                            .onChange(of: task.title) { _ in
                                hasUnsavedChanges = true
                            }
                        Spacer()
                        Button(action: {
                            if let index = tempCategory.tasks.firstIndex(where: { $0.id == task.id }) {
                                tempCategory.tasks.remove(at: index)
                                hasUnsavedChanges = true
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                Button(action: {
                    tempCategory.tasks.append(Task(title: "Nueva Tarea", isCompleted: false))
                    hasUnsavedChanges = true
                }) {
                    Text("Agregar Nueva Tarea")
                }
            }
        }
        .navigationTitle("Editar Categoría")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar Cambios") {
                            category = tempCategory
                            hasUnsavedChanges = false
                            presentationMode.wrappedValue.dismiss()
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
