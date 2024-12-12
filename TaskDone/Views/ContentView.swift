import SwiftUI
struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()

    var body: some View {
        NavigationView {
            VStack {
                
                
                ScrollView {
                    ForEach(viewModel.categories) { category in
                        TaskCard(category: category, expandedCategoryId: $viewModel.expandedCategoryId)
                            .padding()
                    }
                }
                
                
                NavigationLink(destination: CreateCategoryView()) {
                    Text("Crear Nueva Categoría")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }

            }
            .navigationTitle("To-Do List")
            .toolbar {
                
                if let expandedCategoryId = viewModel.expandedCategoryId,
                   let categoryIndex = viewModel.categories.firstIndex(where: { $0.id == expandedCategoryId }) {
                    NavigationLink(destination: EditCategoryView(category: $viewModel.categories[categoryIndex])) {
                        Text("Editar")
                    }
                }
            }
        }
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
