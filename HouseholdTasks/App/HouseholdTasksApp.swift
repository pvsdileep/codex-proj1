import SwiftUI

@main
struct HouseholdTasksApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .onAppear {
                    NotificationScheduler.shared.requestAuth()
                }
        }
    }
}
