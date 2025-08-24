import WidgetKit
import SwiftUI
import CoreData

struct TasksEntry: TimelineEntry {
    let date: Date
    let items: [Item]

    struct Item: Identifiable {
        let id = UUID()
        let title: String
        let time: String
        let priority: Int
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TasksEntry {
        TasksEntry(date: Date(), items: sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (TasksEntry) -> Void) {
        completion(TasksEntry(date: Date(), items: fetchTasks()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TasksEntry>) -> Void) {
        let entry = TasksEntry(date: Date(), items: fetchTasks())
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private var sample: [TasksEntry.Item] {
        [
            .init(title: "Take out trash", time: "7:00 PM", priority: 2),
            .init(title: "Dinner prep", time: "7:30 PM", priority: 1),
            .init(title: "Water plants", time: "8:00 PM", priority: 0)
        ]
    }

    private func fetchTasks() -> [TasksEntry.Item] {
        guard let storeURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourcompany.householdtasks")?
            .appendingPathComponent("HouseholdTasks.sqlite") else { return [] }

        let desc = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: "HouseholdTasks")
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores(completionHandler: { _, _ in })

        let context = container.viewContext
        let req = NSFetchRequest<NSManagedObject>(entityName: "TodoTask")
        req.predicate = NSPredicate(format: "isCompleted == NO AND dueAt != nil")
        req.sortDescriptors = [NSSortDescriptor(key: "dueAt", ascending: true)]
        req.fetchLimit = 5

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let tasks = (try? context.fetch(req)) ?? []
        return tasks.map { obj in
            let title = obj.value(forKey: "title") as? String ?? "Task"
            let due = obj.value(forKey: "dueAt") as? Date ?? Date()
            let priority = obj.value(forKey: "priority") as? Int ?? 0
            return TasksEntry.Item(title: title, time: formatter.string(from: due), priority: priority)
        }
    }
}

struct TasksWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "sun.max")
                Text("My Day").font(.headline)
                Spacer()
            }
            ForEach(entry.items.prefix(3)) { item in
                HStack(spacing: 8) {
                    priorityDot(item.priority)
                    Text(item.title).lineLimit(1)
                    Spacer()
                    Text(item.time).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .widgetURL(URL(string: "householdtasks://myday"))
    }

    func priorityDot(_ p: Int) -> some View {
        let color: Color = p >= 2 ? .red : (p == 1 ? .orange : .green)
        return Circle().fill(color).frame(width: 8, height: 8)
    }
}

struct TasksWidget: Widget {
    let kind: String = "TasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TasksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Day")
        .description("Shows your next tasks today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

