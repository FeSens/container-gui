import SwiftUI

struct ContainerListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ContainerListViewModel?

    var body: some View {
        @Bindable var appState = appState

        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.containers.isEmpty {
                    ProgressView("Loading containers...")
                } else if let error = viewModel.errorMessage, viewModel.containers.isEmpty {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else if viewModel.filteredContainers.isEmpty {
                    if viewModel.containers.isEmpty {
                        EmptyStateView(
                            title: "No Containers",
                            description: "No containers found. Use the CLI to run a container.",
                            systemImage: "shippingbox"
                        )
                    } else {
                        EmptyStateView(
                            title: "No Results",
                            description: "No containers match your search.",
                            systemImage: "magnifyingglass"
                        )
                    }
                } else {
                    List(viewModel.filteredContainers, selection: $appState.selectedContainerID) { container in
                        ContainerRowView(container: container)
                            .tag(container.id)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .searchable(text: searchText, prompt: "Search containers")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Toggle(isOn: runningOnly) {
                    Label("Running", systemImage: runningOnly.wrappedValue ? "play.circle.fill" : "play.circle")
                        .labelStyle(.titleAndIcon)
                        .padding(.trailing, 4)
                }
                .toggleStyle(.button)
                .help("Show running containers only")

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
            let vm = ContainerListViewModel(service: appState.containerService)
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

    private var runningOnly: Binding<Bool> {
        Binding(
            get: { viewModel?.showRunningOnly ?? false },
            set: { viewModel?.showRunningOnly = $0 }
        )
    }
}
