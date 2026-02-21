import SwiftUI

struct BuilderView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: BuilderViewModel?
    @State private var showDeleteConfirmation = false

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.builderStatus == nil {
                    ProgressView("Loading builder status...")
                } else if let status = viewModel.builderStatus {
                    builderDetail(status, viewModel: viewModel)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    EmptyStateView(
                        title: "No Builder",
                        description: "The builder has not been created or has been deleted.",
                        systemImage: "hammer"
                    )
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Builder")
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
        .task {
            let vm = BuilderViewModel(service: appState.builderService)
            viewModel = vm
            vm.startPolling()
        }
        .onDisappear {
            viewModel?.stopPolling()
        }
        .onChange(of: appState.refreshTrigger) {
            Task { await viewModel?.refresh() }
        }
        .alert("Delete Builder?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel?.delete()
                    appState.requestRefresh()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the builder instance.")
        }
    }

    @ViewBuilder
    private func builderDetail(_ status: BuilderStatus, viewModel: BuilderViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(status, viewModel: viewModel)
                Divider()
                infoSection(status)
                Divider()
                resourcesSection(status)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func headerSection(_ status: BuilderStatus, viewModel: BuilderViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(status.id)
                    .font(.title2.bold())
                StatusBadge(status: status.state)
            }
            Spacer()
            actionButtons(status, viewModel: viewModel)
        }
    }

    @ViewBuilder
    private func actionButtons(_ status: BuilderStatus, viewModel: BuilderViewModel) -> some View {
        HStack(spacing: 8) {
            if viewModel.actionInProgress {
                ProgressView()
                    .controlSize(.small)
            }

            if status.isStopped {
                Button {
                    Task {
                        await viewModel.start()
                        appState.requestRefresh()
                    }
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .disabled(viewModel.actionInProgress)
            }

            if status.isRunning {
                Button {
                    Task {
                        await viewModel.stop()
                        appState.requestRefresh()
                    }
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .disabled(viewModel.actionInProgress)
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(viewModel.actionInProgress || status.isRunning)
        }
    }

    @ViewBuilder
    private func infoSection(_ status: BuilderStatus) -> some View {
        DetailSection(title: "Information") {
            DetailRow(label: "ID", value: status.id)
            DetailRow(label: "Image", value: status.image)
            DetailRow(label: "State", value: status.state.capitalized)
            if !status.address.isEmpty {
                DetailRow(label: "Address", value: status.address)
            }
        }
    }

    @ViewBuilder
    private func resourcesSection(_ status: BuilderStatus) -> some View {
        DetailSection(title: "Resources") {
            DetailRow(label: "CPUs", value: status.cpus)
            DetailRow(label: "Memory", value: status.memory)
        }
    }
}
