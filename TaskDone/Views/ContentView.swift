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
                                    .transition(.opacity)
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
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Si la categoría actual está expandida, colapsarla antes de ocultar
                        if expandedCategoryId == category.id {
                            expandedCategoryId = nil
                        }

                        // Ocultar la categoría
                        viewModel.hideCategory(category.objectID)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.fetchCategories()
                        }
                    }
                }) {
                    Label("category-delete", systemImage: "trash")
                }
                
                Button(action: {
                    viewModel.duplicateCategory(categoryId: category.id)
                }) {
                    Label("category-duplicate", systemImage: "doc.on.doc")
                }
            }
            .transition(.opacity)
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
}