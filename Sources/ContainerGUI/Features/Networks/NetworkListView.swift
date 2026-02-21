import SwiftUI

struct NetworkListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: NetworkListViewModel?

    var body: some View {
        @Bindable var appState = appState

        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.networks.isEmpty {
                    ProgressView("Loading networks...")
                } else if let error = viewModel.errorMessage, viewModel.networks.isEmpty {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else if viewModel.filteredNetworks.isEmpty {
                    if viewModel.networks.isEmpty {
                        EmptyStateView(
                            title: "No Networks",
                            description: "No networks found. Use the CLI to create a network.",
                            systemImage: "network"
                        )
                    } else {
                        EmptyStateView(
                            title: "No Results",
                            description: "No networks match your search.",
                            systemImage: "magnifyingglass"
                        )
                    }
                } else {
                    List(viewModel.filteredNetworks, selection: $appState.selectedNetworkID) { network in
                        NetworkRowView(network: network)
                            .tag(network.id)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .searchable(text: searchText, prompt: "Search networks")
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
            let vm = NetworkListViewModel(service: appState.networkService)
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
