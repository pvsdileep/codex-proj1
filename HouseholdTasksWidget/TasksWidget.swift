import WidgetKit
import SwiftUI

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
        completion(TasksEntry(date: Date(), items: sample))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TasksEntry>) -> Void) {
        // TODO: Replace with shared-store fetch via App Group
        let entry = TasksEntry(date: Date(), items: sample)
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

