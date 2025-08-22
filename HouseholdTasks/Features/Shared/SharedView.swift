import SwiftUI
import CoreData

private enum AssigneeFilter: String, CaseIterable, Identifiable {
    case all = "All", me = "Me", partner = "Partner", both = "Both"
    var id: String { rawValue }
}

struct SharedView: View {
    @Environment(\.managedObjectContext) private var ctx
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: "createdAt", ascending: true)
    ], predicate: NSPredicate(format: "list.isShared == YES AND isCompleted == NO"))
    private var tasks: FetchedResults<TodoTask>

    @State private var showingShare = false
    @State private var listToShare: ListEntity?
    @State private var filter: AssigneeFilter = .all
    @State private var showingEditor = false
    @State private var editingTask: TodoTask? = nil

    var body: some View {
        VStack(spacing: 8) {
            Picker("Assignee", selection: $filter) {
                ForEach(AssigneeFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .top])

            List {
                let now = Date()
                let filtered = filteredTasks(tasks: Array(tasks))
                let overdue = filtered.filter { ($0.dueAt ?? .distantFuture) < now }
                    .sorted(by: sortShared)
                let upcoming = filtered.filter { ($0.dueAt ?? .distantFuture) >= now }
                    .sorted(by: sortShared)

                if !overdue.isEmpty {
                    Section("Overdue") {
                        ForEach(overdue) { task in TaskRow(task: task, onEdit: { t in editingTask = t; showingEditor = true }) }
                    }
                }
                Section(overdue.isEmpty ? "Tasks" : "Upcoming") {
                    ForEach(upcoming) { task in TaskRow(task: task, onEdit: { t in editingTask = t; showingEditor = true }) }
                }
            }

            HStack {
                Button("New Task") {
                    editingTask = nil
                    showingEditor = true
                }
                Spacer()
                #if !LOCAL_ONLY
                Button("Share List") {
                    listToShare = fetchOrCreateSharedList()
                    showingShare = true
                }
                #else
                Text("iCloud sharing disabled")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                #endif
            }
            .padding()
        }
        #if !LOCAL_ONLY
        .sheet(isPresented: $showingShare) {
            if let list = listToShare { CloudShareView(object: list) }
        }
        #endif
        .sheet(isPresented: $showingEditor) {
            TaskEditView(mode: editingTask == nil ? .create : .edit,
                         list: editingTask?.list ?? fetchOrCreateSharedList(),
                         taskToEdit: editingTask)
        }
        .navigationTitle("Shared")
    }

    private func sortShared(_ lhs: TodoTask, _ rhs: TodoTask) -> Bool {
        let lDue = lhs.dueAt ?? .distantFuture
        let rDue = rhs.dueAt ?? .distantFuture
        if lDue == rDue { return lhs.priority > rhs.priority }
        return lDue < rDue
    }

    private func matchesAssignee(_ task: TodoTask) -> Bool {
        let a = task.assignee ?? ""
        switch filter {
        case .all: return true
        case .me: return a == "you" || a == "both"
        case .partner: return a == "partner" || a == "both"
        case .both: return a == "both"
        }
    }

    private func filteredTasks(tasks: [TodoTask]) -> [TodoTask] {
        tasks.filter { matchesAssignee($0) }
    }

    private func fetchOrCreateSharedList() -> ListEntity {
        let req: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isShared == YES")
        if let found = try? ctx.fetch(req).first { return found }
        let list = ListEntity(context: ctx)
        list.id = UUID()
        list.name = "Shared"
        list.isShared = true
        try? ctx.save()
        return list
    }

    // creation now handled by TaskEditView
}
