import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedSection: Int = 0
    @State private var showAddTaskView: Bool = false
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                HStack {
                    Text(getCurrentTime())
                        .font(.title3)
                        .accentColor(Color.dateText)
                    Spacer()
                    Text(getCurrentDay())
                        .font(.largeTitle)
                        .accentColor(Color.dateText)
                    Text(getCurrentMonth())
                        .font(.title3)
                        .accentColor(Color.dateText)
                }
            }
            .padding(.horizontal, 50)
            .frame(maxWidth: .infinity)
            Picker("Sections", selection: $selectedSection) {
                Text("Próximamente").tag(0)
                Text("Vencidas").tag(1)
                Text("Completadas").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.accentBackground.opacity(0.4)) 
            .cornerRadius(10) 
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.accentBackground, lineWidth: 2) 
            )
            .padding(.horizontal, 30)
            .tint(.red)
            List {
                if selectedSection == 0 {
                    ForEach(viewModel.upcomingTasks) { task in
                        TaskRow(task: task, viewModel: viewModel)
                    }
                } else if selectedSection == 1 {
                    ForEach(viewModel.overdueTasks) { task in
                        TaskRow(task: task, viewModel: viewModel, isEditable: false)
                    }
                } else if selectedSection == 2 {
                    ForEach(viewModel.completedTasks) { task in
                        TaskRow(task: task, viewModel: viewModel, isEditable: false)
                    }
                }
            }
            .listStyle(PlainListStyle())
            Button(action: {
                showAddTaskView = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding()
                    .background(Color.accentBackground)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(viewModel: viewModel)
                    .presentationDetents([.small])
            }
            .padding()
        }
        .background(Color.background) 
        .onAppear {
            viewModel.cleanOldTasks()
        }
    }
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    func getCurrentDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }
    func getCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}