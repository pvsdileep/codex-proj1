import SwiftUI

struct AssigneeBadge: View {
    let assignee: String?

    private var label: String {
        switch (assignee ?? "") {
        case "you": return "Me"
        case "partner": return "Partner"
        case "both": return "Both"
        default: return "Unassigned"
        }
    }

    private var color: Color {
        switch (assignee ?? "") {
        case "you": return .blue
        case "partner": return .purple
        case "both": return .teal
        default: return .gray
        }
    }

    var body: some View {
        Text(label)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
