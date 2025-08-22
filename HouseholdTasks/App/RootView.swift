import SwiftUI

struct RootView: View {
    @State private var selected: Tab = .myday

    enum Tab: Hashable { case myday, shared }

    var body: some View {
        TabView(selection: $selected) {
            NavigationStack { MyDayView() }
                .tabItem { Label("My Day", systemImage: "sun.max") }
                .tag(Tab.myday)

            NavigationStack { SharedView() }
                .tabItem { Label("Shared", systemImage: "person.2") }
                .tag(Tab.shared)
        }
        .onOpenURL { url in
            switch url.host ?? url.pathComponents.dropFirst().first ?? "" {
            case "myday": selected = .myday
            case "shared": selected = .shared
            default: break
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View { RootView() }
}
