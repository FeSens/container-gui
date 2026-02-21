import SwiftUI

struct VolumeListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: VolumeListViewModel?

    var body: some View {
        @Bindable var appState = appState

        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.volumes.isEmpty {
                    ProgressView("Loading volumes...")
                } else if let error = viewModel.errorMessage, viewModel.volumes.isEmpty {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else if viewModel.filteredVolumes.isEmpty {
                    if viewModel.volumes.isEmpty {
                        EmptyStateView(
                            title: "No Volumes",
                            description: "No volumes found. Create a volume to get started.",
                            systemImage: "externaldrive"
                        )
                    } else {
                        EmptyStateView(
                            title: "No Results",
                            description: "No volumes match your search.",
                            systemImage: "magnifyingglass"
                        )
                    }
                } else {
                    List(viewModel.filteredVolumes, selection: $appState.selectedVolumeName) { volume in
                        VolumeRowView(volume: volume)
                            .tag(volume.id)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .searchable(text: searchText, prompt: "Search volumes")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    Task { await viewModel?.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 450)
        .task {
            let vm = VolumeListViewModel(service: appState.volumeService)
            viewModel = vm
            vm.startPolling()
        }
        .onDisappear {
            viewModel?.stopPolling()
        }
        .onChange(of: appState.refreshTrigger) {
            Task { await viewModel?.refresh() }
        }
    }

    private var searchText: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }
}
