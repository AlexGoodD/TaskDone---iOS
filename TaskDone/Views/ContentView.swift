import SwiftUI
struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Tasks")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)

                HStack {
                    Text("Create and manage your task by category")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .bold()
                    Spacer()
                       
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                ScrollView {
                    ForEach(viewModel.categories) { category in
                        TaskCard(category: category, expandedCategoryId: $viewModel.expandedCategoryId)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let expandedCategoryId = viewModel.expandedCategoryId,
                       let categoryIndex = viewModel.categories.firstIndex(where: { $0.id == expandedCategoryId }) {
                        NavigationLink(destination: EditCategoryView(category: $viewModel.categories[categoryIndex])) {
                            Image(systemName: "highlighter")
                                .foregroundColor(.blue)
                        }
                    } else {
                        Image(systemName: "highlighter")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .environmentObject(viewModel) 
    }
}
#Preview {
    ContentView().environmentObject(TaskViewModel())
}
