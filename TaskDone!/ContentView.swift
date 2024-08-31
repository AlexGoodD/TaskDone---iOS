import SwiftUI

struct ContentView: View {
    
    init() {
        // Color de fondo del segmento seleccionado
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "TabBackground")
        
        // Color del texto para el segmento seleccionado
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        // Color del texto para los segmentos no seleccionados
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(named: "MainTextColor") ?? UIColor.black], for: .normal)
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO AND dueDate >= %@", Date() as NSDate)
    ) var upcomingTasks: FetchedResults<Task>
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO AND dueDate < %@", Date() as NSDate)
    ) var overdueTasks: FetchedResults<Task>
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == YES")
    ) var completedTasks: FetchedResults<Task>
    
    @State private var showCreateTaskView: Bool = false
    @State private var selectedTab = "Próximamente"
    @State private var selectedView = "list"
    private let tabs = ["Próximamente", "Vencidas", "Completadas"]
    private let views = ["list", "calendar"]
    
    
    var body: some View {
        VStack {
            // Encabezado con la fecha y hora
            HStack {
                VStack {
                    Text(Date(), style: .time)
                        .font(.system(size: 22, weight: .medium))
                    Spacer()
                }
                .frame(height: 70)
                
                Spacer()
                
                Text(Date(), formatter: monthDayFormatter)
                    .font(.system(size: 80, weight: .bold))
                
                Spacer()
                
                VStack {
                    Spacer()
                    Text(Date(), formatter: monthNameFormatter)
                        .font(.system(size: 30))
                        .padding(.top, -20)
                }
                .frame(height: 70)
                
            }
            .foregroundColor(Color("MainTextColor"))
            .padding(.horizontal, 40)
            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            
            
            
            // Pestañas de navegación
            Picker("", selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab)
                        .tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Listado de tareas según la pestaña seleccionada
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if selectedTab == "Próximamente" {
                        ForEach(upcomingTasks) { task in
                            TaskRow(task: task)
                        }
                    } else if selectedTab == "Vencidas" {
                        ForEach(overdueTasks) { task in
                            TaskRow(task: task)
                        }
                    } else if selectedTab == "Completadas" {
                        ForEach(completedTasks) { task in
                            TaskRow(task: task)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Barra de navegación inferior
            HStack {
                
                VStack{
                    Button(action: {
                        showCreateTaskView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color("TabSelectBackground"))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .padding(.bottom, 5)
                    }
                    .sheet(isPresented: $showCreateTaskView) {
                        CreateTaskView().environment(\.managedObjectContext, viewContext)
                            .presentationDetents([.fraction(0.3)])
                    }
                    
                        
                    Picker("", selection: $selectedView) {
                        Image(systemName: "list.bullet") // Ícono de lista
                            .tag("list")
                        Image(systemName: "calendar") // Ícono de calendario
                            .tag("calendar")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 50)
                }
            }
            .padding(.horizontal, 100)
            .frame(height: 50)
        }
        .background(Color("Background"))
    }
}

struct TaskRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title ?? "Sin título")
                    .font(.headline)
                Text("Vencimiento: \(task.dueDate ?? Date(), formatter: taskDateFormatter)")
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            Spacer()
            Button(action: {
                task.isCompleted.toggle()
                do {
                    try viewContext.save()
                } catch {
                    print("Error al actualizar la tarea: \(error)")
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 25))
                    .foregroundColor(task.isCompleted ? Color("TaskBorderColor") : Color("TaskBorderColor") )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 25)
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("TaskBackground"))
                .opacity(0.8)// Cambia el fondo a un color
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("TaskBorderColor"), lineWidth: 2.5) // Añade el borde alrededor del fondo
        )
    }
}

struct NavigationButton: View {
    var iconName: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 25))
                .padding()
                .background(Color("TabSelectBackground"))
                .cornerRadius(25)
        }
    }
}

private let taskDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy HH:mm" // Formato personalizado para mostrar la fecha y hora
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

private let monthNameFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter
}()

private let monthDayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.colorScheme, .light)
    }
}
