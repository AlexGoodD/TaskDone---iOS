import SwiftUI

struct CreateTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var taskDueDate: Date = Date()
    
    var body: some View {
        ZStack {
            Color("Background") // Aplica el color a toda la vista
                .edgesIgnoringSafeArea(.all) // Ignora los límites seguros para que el color cubra toda la ventana
            
            VStack {
                Section {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancelar")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(Color.red)

                    }
                }
                
                HStack{
                    Text("Título de la tarea: ")
                    TextField("", text: $taskTitle)
                }
                HStack{
                    Text("Descripción: ")
                    TextField("", text: $taskDescription)
                }
                DatePicker("Fecha de vencimiento:", selection: $taskDueDate, displayedComponents: .date)
                DatePicker("Hora de vencimiento:", selection: $taskDueDate, displayedComponents: .hourAndMinute)
                
                Section {
                    Button(action: {
                        addTask()
                    }) {
                        Text("Guardar")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.blue)
                            
                    }
                }
                .padding(.top, 5)
            }
            .foregroundColor(Color("MainTextColor"))

            .padding(.horizontal, 30)
            .frame(height: 1)
        }
        .navigationTitle("Nueva tarea")
        .navigationBarItems(trailing: Button("Cancelar") {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    private func addTask() {
        let newTask = Task(context: viewContext)
        newTask.title = taskTitle
        newTask.taskDescription = taskDescription
        newTask.dueDate = taskDueDate
        newTask.isCompleted = false
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error al guardar la tarea: \(error)")
        }
    }
}

struct CreateTaskView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
