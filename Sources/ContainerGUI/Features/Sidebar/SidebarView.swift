import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        List(SidebarCategory.allCases, selection: $appState.selectedCategory) { category in
            Label(category.title, systemImage: category.icon)
                .tag(category)
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 260)
    }
}
