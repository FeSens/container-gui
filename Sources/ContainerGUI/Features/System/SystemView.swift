import SwiftUI

struct SystemView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: SystemViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.diskUsage == nil {
                    ProgressView("Loading system status...")
                } else if let error = viewModel.errorMessage, viewModel.diskUsage == nil && viewModel.statusText == nil {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    systemDetail(viewModel: viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("System")
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
            let vm = SystemViewModel(service: appState.systemService)
            viewModel = vm
            await vm.refresh()
        }
        .onChange(of: appState.refreshTrigger) {
            Task { await viewModel?.refresh() }
        }
    }

    @ViewBuilder
    private func systemDetail(viewModel: SystemViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(viewModel: viewModel)

                if let statusText = viewModel.statusText {
                    Divider()
                    statusSection(statusText)
                }

                if let usage = viewModel.diskUsage {
                    Divider()
                    containersSection(usage.containers)
                    Divider()
                    imagesSection(usage.images)
                    Divider()
                    volumesSection(usage.volumes)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func headerSection(viewModel: SystemViewModel) -> some View {
        HStack {
            Text("System")
                .font(.title2.bold())
            Spacer()
            actionButtons(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private func actionButtons(viewModel: SystemViewModel) -> some View {
        HStack(spacing: 8) {
            if viewModel.actionInProgress {
                ProgressView()
                    .controlSize(.small)
            }

            Button {
                Task {
                    await viewModel.startServices()
                    appState.requestRefresh()
                }
            } label: {
                Label("Start", systemImage: "play.fill")
            }
            .disabled(viewModel.actionInProgress)

            Button {
                Task {
                    await viewModel.stopServices()
                    appState.requestRefresh()
                }
            } label: {
                Label("Stop", systemImage: "stop.fill")
            }
            .disabled(viewModel.actionInProgress)
        }
    }

    @ViewBuilder
    private func statusSection(_ statusText: String) -> some View {
        DetailSection(title: "Status") {
            Text(statusText)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func containersSection(_ entry: DiskUsageEntry) -> some View {
        DetailSection(title: "Containers") {
            DetailRow(label: "Total", value: "\(entry.total)")
            DetailRow(label: "Active", value: "\(entry.active)")
            DetailRow(label: "Size", value: entry.sizeInBytes.formattedBytes)
            DetailRow(label: "Reclaimable", value: entry.reclaimable.formattedBytes)
        }
    }

    @ViewBuilder
    private func imagesSection(_ entry: DiskUsageEntry) -> some View {
        DetailSection(title: "Images") {
            DetailRow(label: "Total", value: "\(entry.total)")
            DetailRow(label: "Active", value: "\(entry.active)")
            DetailRow(label: "Size", value: entry.sizeInBytes.formattedBytes)
            DetailRow(label: "Reclaimable", value: entry.reclaimable.formattedBytes)
        }
    }

    @ViewBuilder
    private func volumesSection(_ entry: DiskUsageEntry) -> some View {
        DetailSection(title: "Volumes") {
            DetailRow(label: "Total", value: "\(entry.total)")
            DetailRow(label: "Active", value: "\(entry.active)")
            DetailRow(label: "Size", value: entry.sizeInBytes.formattedBytes)
            DetailRow(label: "Reclaimable", value: entry.reclaimable.formattedBytes)
        }
    }
}
