import SwiftUI

struct PriorityBadge: View {
    let priority: TaskPriority

    var body: some View {
        let label = ["Low", "Med", "High"][Int(priority.rawValue)]
        let color: Color = [.green, .orange, .red][Int(priority.rawValue)]
        Text(label)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
