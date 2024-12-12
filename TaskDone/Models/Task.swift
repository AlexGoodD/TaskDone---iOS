import Foundation

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}