import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var expandedCategoryId: UUID?

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("tasks_title")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack {
                    Text("tasks_subtitle")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                ScrollView {
                    VStack(spacing: 10) {
                        if viewModel.categories.isEmpty {
                            Text("no-available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.categories, id: \.id) { category in
                                CategoryRow(category: category, expandedCategoryId: $expandedCategoryId)
                                    .animation(.easeInOut(duration: 0.3), value: expandedCategoryId)
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let expandedCategoryId = expandedCategoryId,
                       let category = viewModel.categories.first(where: { $0.id == expandedCategoryId }) {
                        NavigationLink(
                            destination: EditCategoryView(category: .constant(category))
                                .environmentObject(viewModel)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.expandedCategoryId = nil 
                                    }
                                }
                        ) {
                            Image(systemName: "highlighter")
                                .foregroundColor(.blue)
                        }
                    } else {
                        Image(systemName: "highlighter")
                            .foregroundColor(.gray)
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    NavigationLink(
                        destination: CreateCategoryView()
                            .environmentObject(viewModel)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.expandedCategoryId = nil 
                                }
                            }
                    ) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .blue, radius: 10)
                    }
                    .padding(.bottom, 30)
                    Spacer()
                }
            }
            .onAppear {
                viewModel.fetchCategories()
            }
        }
        .environmentObject(viewModel) // Asegúrate de pasar el environmentObject aquí
    }
}

struct CategoryRow: View {
    var category: TaskCategory
    @Binding var expandedCategoryId: UUID?
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        TaskCard(category: category, expandedCategoryId: $expandedCategoryId)
            .contextMenu {
                Button(role: .destructive) {
                    withAnimation {
                        // Si la categoría actual está expandida, colapsarla antes de ocultar
                        if expandedCategoryId == category.id {
                            expandedCategoryId = nil
                        }

                        // Ocultar la categoría
                        viewModel.hideCategory(category.objectID)
                    }
                } label: {
                    Label("category-delete", systemImage: "trash")
                }
            }
    }
}

#Preview {
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
    task1.creationDate = Date()
    task1.category = exampleCategory
    
    let task2 = Task(entity: taskEntity, insertInto: exampleContext)
    task2.id = UUID()
    task2.title = "Ejemplo Tarea 2"
    task2.isCompleted = true
    task2.creationDate = Date().addingTimeInterval(-86400) // Un día antes
    task2.category = exampleCategory
    
    exampleCategory.addToTasks(task1)
    exampleCategory.addToTasks(task2)
    
    let viewModel = TaskViewModel(context: exampleContext)
    viewModel.categories = [exampleCategory]
    
    return ContentView()
        .environment(\.managedObjectContext, exampleContext)
        .environmentObject(viewModel)
}