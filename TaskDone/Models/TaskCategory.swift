import SwiftUI

struct TaskCategory: Identifiable {
    var id = UUID()
    var name: String
    var color: Color
    var tasks: [Task]
}