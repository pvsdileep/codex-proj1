import SwiftUI

struct TaskRow: View {
    @Environment(\.managedObjectContext) private var ctx
    @ObservedObject var task: TodoTask
    var onEdit: ((TodoTask) -> Void)? = nil

    var body: some View {
        HStack {
            Button(action: { task.isCompleted.toggle(); try? ctx.save() }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            VStack(alignment: .leading) {
                Text(task.title ?? "").font(.body)
                HStack(spacing: 8) {
                    if let due = task.dueAt { Text(due, style: .time) }
                    PriorityBadge(priority: task.priorityEnum)
                    AssigneeBadge(assignee: task.assignee)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 12) {
                Menu {
                    Button("Snooze 10m") { NotificationScheduler.shared.snooze(task: task, minutes: 10) }
                    Button("Snooze 30m") { NotificationScheduler.shared.snooze(task: task, minutes: 30) }
                    Button("Snooze 1h")  { NotificationScheduler.shared.snooze(task: task, minutes: 60) }
                } label: { Image(systemName: "bell.badge") }

                Menu {
                    // Priority
                    Section("Priority") {
                        Button { setPriority(.high) } label: { Label("High", systemImage: "exclamationmark.3") }
                        Button { setPriority(.medium) } label: { Label("Medium", systemImage: "exclamationmark.2") }
                        Button { setPriority(.low) } label: { Label("Low", systemImage: "exclamationmark") }
                    }
                    // Assignee
                    Section("Assign to") {
                        Button { setAssignee("you") } label: { Label("Me", systemImage: "person") }
                        Button { setAssignee("partner") } label: { Label("Partner", systemImage: "person.fill") }
                        Button { setAssignee("both") } label: { Label("Both", systemImage: "person.2") }
                    }
                    // Move to bucket
                    Section("Move to") {
                        Button { moveTo(.next) } label: { Label("Next bucket", systemImage: "arrowshape.turn.up.right") }
                        Button { moveTo(.morning) } label: { Label("Morning 9:00", systemImage: "sunrise") }
                        Button { moveTo(.afternoon) } label: { Label("Afternoon 2:00", systemImage: "sun.max") }
                        Button { moveTo(.evening) } label: { Label("Evening 8:00", systemImage: "moon") }
                        Button { moveTo(.tomorrowMorning) } label: { Label("Tomorrow morning", systemImage: "calendar") }
                    }
                    Button { onEdit?(task) } label: { Label("Edit", systemImage: "square.and.pencil") }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onEdit?(task) }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button { setPriority(.high) } label: { Label("High", systemImage: "exclamationmark.3") }.tint(.red)
            Button { setPriority(.medium) } label: { Label("Med", systemImage: "exclamationmark.2") }.tint(.orange)
            Button { setPriority(.low) } label: { Label("Low", systemImage: "exclamationmark") }.tint(.green)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button { task.isCompleted.toggle(); try? ctx.save() } label: { Label("Done", systemImage: "checkmark") }.tint(.blue)
        }
    }

    private func setPriority(_ p: TaskPriority) {
        task.priorityEnum = p
        try? ctx.save()
    }

    private func setAssignee(_ a: String) {
        task.assignee = a
        try? ctx.save()
    }

    // MARK: - Move to time buckets
    private enum TimeBucket { case morning, afternoon, evening, tomorrowMorning, next }

    private func moveTo(_ bucket: TimeBucket) {
        let target: Date
        switch bucket {
        case .morning: target = anchor(hour: 9, minute: 0, allowTodayIfFuture: true) ?? Date()
        case .afternoon: target = anchor(hour: 14, minute: 0, allowTodayIfFuture: true) ?? Date()
        case .evening: target = anchor(hour: 20, minute: 0, allowTodayIfFuture: true) ?? Date()
        case .tomorrowMorning: target = anchor(hour: 9, minute: 0, allowTodayIfFuture: false) ?? Date().addingTimeInterval(24*60*60)
        case .next:
            let nowHour = Calendar.current.component(.hour, from: Date())
            if nowHour < 12 { target = anchor(hour: 14, minute: 0, allowTodayIfFuture: true) ?? Date() }
            else if nowHour < 18 { target = anchor(hour: 20, minute: 0, allowTodayIfFuture: true) ?? Date() }
            else { target = anchor(hour: 9, minute: 0, allowTodayIfFuture: false) ?? Date().addingTimeInterval(24*60*60) }
        }

        task.dueAt = target
        try? ctx.save()
        NotificationScheduler.shared.cancelNotifications(for: task) {
            NotificationScheduler.shared.schedule(task: task)
        }
    }

    private func anchor(hour: Int, minute: Int, allowTodayIfFuture: Bool) -> Date? {
        let cal = Calendar.current
        let now = Date()
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = hour; comps.minute = minute
        let today = cal.date(from: comps)
        if allowTodayIfFuture, let today, today > now { return today }
        return cal.date(byAdding: .day, value: 1, to: today ?? now).map { cal.date(bySettingHour: hour, minute: minute, second: 0, of: $0) ?? $0 }
    }
}
