import SwiftUI
import CoreData

struct MyDayView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest var tasks: FetchedResults<TodoTask>
    @State private var showingEditor = false
    @State private var editingTask: TodoTask? = nil

    init() {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: start) ?? Date()
        let request: NSFetchRequest<TodoTask> = TodoTask.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO AND dueAt <= %@", end as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(key: "dueAt", ascending: true),
            NSSortDescriptor(key: "priority", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        _tasks = FetchRequest(fetchRequest: request, animation: .default)
    }

    var body: some View {
        List {
            let now = Date()
            let all = Array(tasks)
            let overdue = all.filter { ($0.dueAt ?? .distantFuture) < now }
                .sorted(by: sortMyDay)
            let upcoming = all.filter { ($0.dueAt ?? .distantFuture) >= now }

            if !overdue.isEmpty {
                Section("Overdue") {
                    ForEach(overdue) { task in
                        TaskRow(task: task, onEdit: { t in
                            editingTask = t
                            showingEditor = true
                        })
                    }
                }
            }

            let grouped = Dictionary(grouping: upcoming) { bucket(for: $0.dueAt) }
            ForEach(timeBucketOrder, id: \.self) { bucketName in
                if let items = grouped[bucketName], !items.isEmpty {
                    Section(bucketName) {
                        ForEach(items.sorted(by: sortMyDay)) { task in
                            TaskRow(task: task, onEdit: { t in
                                editingTask = t
                                showingEditor = true
                            })
                        }
                    }
                }
            }
        }
        .navigationTitle("My Day")
        .toolbar { ToolbarItem(placement: .navigationBarTrailing) { addButton } }
        .sheet(isPresented: $showingEditor) {
            TaskEditView(mode: editingTask == nil ? .create : .edit, list: nil, taskToEdit: editingTask)
        }
    }

    private var addButton: some View {
        Button {
            editingTask = nil
            showingEditor = true
        } label: { Image(systemName: "plus") }
    }

    private var timeBucketOrder: [String] { ["Morning", "Afternoon", "Evening"] }

    private func bucket(for date: Date?) -> String {
        guard let date else { return "Evening" }
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0...11: return "Morning"
        case 12...17: return "Afternoon"
        default: return "Evening"
        }
    }

    private func sortMyDay(_ lhs: TodoTask, _ rhs: TodoTask) -> Bool {
        let lDue = lhs.dueAt ?? .distantFuture
        let rDue = rhs.dueAt ?? .distantFuture
        if lDue == rDue { return lhs.priority > rhs.priority }
        return lDue < rDue
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets { ctx.delete(tasks[index]) }
        try? ctx.save()
    }
}
