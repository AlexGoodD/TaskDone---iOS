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
            /*
            Section(header: Text("Color de Categoría")) {
                ColorPicker("Color", selection: $tempCategory.color)
                    .onChange(of: tempCategory.color) { _ in
                        hasUnsavedChanges = true
                    }
            }
             */

            Section(header: Text("Tareas")) {
                ForEach(Array(tempCategory.tasks), id: \.id) { task in
                    HStack {
                        TextField("Título", text: Binding(
                            get: { task.title ?? "" },
                            set: { newValue in
                                updateTaskTitle(task: task, newTitle: newValue)
                            }
                        ))
                        Spacer()
                        Button(action: {
                            removeTask(task: task)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                Button(action: addNewTask) {
                    Text("Agregar Nueva Tarea")
                }
            }
        }
        .navigationTitle("Editar Categoría")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar Cambios") {
                    saveChanges()
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

    private func updateTaskTitle(task: Task, newTitle: String) {
        if let index = tempCategory.tasks.firstIndex(where: { $0.id == task.id }) {
            tempCategory.tasks[index].title = newTitle
            hasUnsavedChanges = true
        }
    }

    private func removeTask(task: Task) {
        if let index = tempCategory.tasks.firstIndex(where: { $0.id == task.id }) {
            tempCategory.tasks.remove(at: index)
            hasUnsavedChanges = true
        }
    }

    private func addNewTask() {
        let newTask = Task(context: PersistenceController.shared.container.viewContext)
        newTask.id = UUID()
        newTask.title = "Nueva Tarea"
        newTask.isCompleted = false
        tempCategory.tasks.insert(newTask)
        hasUnsavedChanges = true
    }

    private func saveChanges() {
        category = tempCategory
        hasUnsavedChanges = false
        presentationMode.wrappedValue.dismiss()
    }
}
