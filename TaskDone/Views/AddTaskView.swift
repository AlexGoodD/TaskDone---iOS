import SwiftUI
struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TaskViewModel
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    var body: some View {
        NavigationView {
            Form {
                TextField("Título", text: $title)
                DatePicker("Fecha de vencimiento", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationBarTitle("Nueva Tarea", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Guardar") {
                viewModel.addTask(title: title, dueDate: dueDate)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
#Preview {
    AddTaskView(viewModel: TaskViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}