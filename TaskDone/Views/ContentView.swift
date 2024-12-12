import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var expandedCategoryId: UUID?

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
                    VStack(spacing: 10) {
                        ForEach(viewModel.categories, id: \.id) { category in
                            VStack {
                                TaskCard(category: category, expandedCategoryId: $expandedCategoryId)
                                    .environmentObject(viewModel)
                                
                                if expandedCategoryId == category.id {
                                    NavigationLink(destination: EditCategoryView(category: .constant(category))) {
                                        Text("Edit")
                                            .foregroundColor(.blue)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                    .padding(.top, 5)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateCategoryView().environmentObject(viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(TaskViewModel())
}