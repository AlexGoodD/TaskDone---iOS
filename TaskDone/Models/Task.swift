import Foundation
struct Task: Identifiable {
    let id: UUID = UUID() 
    var title: String     
    var dueDate: Date     
    var isCompleted: Bool = false 
}
extension Task {
    var dueDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy HH:mm"
        return formatter.string(from: dueDate)
    }
}