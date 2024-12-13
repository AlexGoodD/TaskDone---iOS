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
                            TaskCard(category: category, expandedCategoryId: $expandedCategoryId)
                                .environmentObject(viewModel)
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
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
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
                                .shadow(radius: 10)
                        }
                        Spacer()
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView().environmentObject(TaskViewModel())
}
