import SwiftUI
import CoreData

struct TaskEditView: View {
    enum Mode { case create, edit }

    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let list: ListEntity?
    let taskToEdit: TodoTask?

    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueAt: Date
    @State private var priority: TaskPriority
    @State private var assignee: String
    @State private var remind: Bool

    init(mode: Mode, list: ListEntity?, taskToEdit: TodoTask?) {
        self.mode = mode
        self.list = list
        self.taskToEdit = taskToEdit

        let now = Date()
        let t = taskToEdit
        _title = State(initialValue: t?.title ?? "")
        _notes = State(initialValue: t?.notes ?? "")
        let due = t?.dueAt ?? Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        _hasDueDate = State(initialValue: t?.dueAt != nil)
        _dueAt = State(initialValue: due)
        _priority = State(initialValue: t?.priorityEnum ?? .medium)
        _assignee = State(initialValue: t?.assignee ?? (list != nil ? "both" : "you"))
        _remind = State(initialValue: t?.dueAt != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
                Section("When") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueAt, displayedComponents: [.date, .hourAndMinute])
                        Toggle("Remind me at due time", isOn: $remind)
                        if remind {
                            QuickRemindRow(dueAt: $dueAt)
                        }
                    }
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(TaskPriority.low)
                        Text("Medium").tag(TaskPriority.medium)
                        Text("High").tag(TaskPriority.high)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Assignee") {
                    Picker("Assign to", selection: $assignee) {
                        Text("Me").tag("you")
                        Text("Partner").tag("partner")
                        Text("Both").tag("both")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(mode == .create ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let task: TodoTask
        if let existing = taskToEdit {
            task = existing
        } else {
            task = TodoTask(context: ctx)
            task.id = UUID()
            task.createdAt = Date()
            task.isCompleted = false
            task.list = list
        }
        task.title = title
        task.notes = notes.isEmpty ? nil : notes
        task.priorityEnum = priority
        task.assignee = assignee
        task.updatedAt = Date()
        task.dueAt = hasDueDate ? dueAt : nil

        try? ctx.save()

        // Cancel existing notifications first to avoid duplicates
        NotificationScheduler.shared.cancelNotifications(for: task) {
            if remind, let _ = task.dueAt {
                NotificationScheduler.shared.schedule(task: task)
            }
        }
        dismiss()
    }
}

private struct QuickRemindRow: View {
    @Binding var dueAt: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick schedule")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Button("10m") { setOffset(minutes: 10) }
                Button("30m") { setOffset(minutes: 30) }
                Button("1h")  { setOffset(minutes: 60) }
                Button("Tonight") { dueAt = tonight }
                Button("Tomorrow") { dueAt = tomorrowMorning }
            }
            .buttonStyle(.bordered)
        }
    }

    private func setOffset(minutes: Int) { dueAt = Date().addingTimeInterval(Double(minutes * 60)) }

    private var tonight: Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 20; comps.minute = 0
        let today20 = cal.date(from: comps) ?? Date()
        return today20 > Date() ? today20 : cal.date(byAdding: .day, value: 1, to: today20) ?? today20
    }

    private var tomorrowMorning: Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.day = (comps.day ?? 0) + 1
        comps.hour = 9; comps.minute = 0
        return cal.date(from: comps) ?? Date().addingTimeInterval(24*60*60)
    }
}
