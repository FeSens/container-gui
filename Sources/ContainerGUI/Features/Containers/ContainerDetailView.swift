import SwiftUI

struct ContainerDetailView: View {
    let containerID: String
    @Environment(AppState.self) private var appState
    @State private var viewModel: ContainerDetailViewModel?
    @State private var selectedTab: ContainerDetailTab = .info

    enum ContainerDetailTab: String, Hashable {
        case info = "Info"
        case logs = "Logs"
    }

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.container == nil {
                    ProgressView("Loading...")
                } else if let container = viewModel.container {
                    TabView(selection: $selectedTab) {
                        Tab(ContainerDetailTab.info.rawValue, systemImage: "info.circle", value: .info) {
                            containerDetail(container, viewModel: viewModel)
                        }
                        Tab(ContainerDetailTab.logs.rawValue, systemImage: "text.alignleft", value: .logs) {
                            ContainerLogsView(containerID: containerID)
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    EmptyStateView(
                        title: "Container Not Found",
                        description: "The container may have been deleted.",
                        systemImage: "shippingbox"
                    )
                }
            } else {
                ProgressView()
            }
        }
        .task(id: containerID) {
            selectedTab = .info
            let vm = ContainerDetailViewModel(service: appState.containerService)
            viewModel = vm
            await vm.load(id: containerID)
        }
        .alert("Delete Container?", isPresented: deleteConfirmation) {
            Button("Delete", role: .destructive) {
                performAction { await viewModel?.delete() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. The container will be permanently removed.")
        }
    }

    private var deleteConfirmation: Binding<Bool> {
        Binding(
            get: { viewModel?.showDeleteConfirmation ?? false },
            set: { viewModel?.showDeleteConfirmation = $0 }
        )
    }

    @ViewBuilder
    private func containerDetail(_ container: ContainerSummary, viewModel: ContainerDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(container, viewModel: viewModel)
                Divider()
                infoSection(container)
                Divider()
                resourcesSection(container)
                if !container.configuration.mounts.isEmpty {
                    Divider()
                    mountsSection(container)
                }
                if !container.configuration.publishedPorts.isEmpty {
                    Divider()
                    portsSection(container)
                }
                if !container.configuration.initProcess.environment.isEmpty {
                    Divider()
                    environmentSection(container)
                }
                if !container.configuration.labels.isEmpty {
                    Divider()
                    labelsSection(container)
                }
            }
            .padding()
        }
        .navigationTitle(container.configuration.id)
    }

    @ViewBuilder
    private func headerSection(_ container: ContainerSummary, viewModel: ContainerDetailViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(container.configuration.id)
                    .font(.title2.bold())
                StatusBadge(status: container.status)
            }
            Spacer()
            actionButtons(container, viewModel: viewModel)
        }
    }

    private func performAction(_ action: @escaping () async -> Void) {
        Task {
            await action()
            appState.requestRefresh()
            if viewModel?.container == nil {
                appState.selectedContainerID = nil
            }
        }
    }

    @ViewBuilder
    private func actionButtons(_ container: ContainerSummary, viewModel: ContainerDetailViewModel) -> some View {
        HStack(spacing: 8) {
            if viewModel.actionInProgress {
                ProgressView()
                    .controlSize(.small)
            }

            if container.isStopped {
                Button {
                    performAction { await viewModel.start() }
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .disabled(viewModel.actionInProgress)
            }

            if container.isRunning {
                Button {
                    performAction { await viewModel.stop() }
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .disabled(viewModel.actionInProgress)

                Button {
                    performAction { await viewModel.kill() }
                } label: {
                    Label("Kill", systemImage: "xmark.circle.fill")
                }
                .disabled(viewModel.actionInProgress)
            }

            Button(role: .destructive) {
                viewModel.showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(viewModel.actionInProgress || container.isRunning)
        }
    }

    @ViewBuilder
    private func infoSection(_ container: ContainerSummary) -> some View {
        DetailSection(title: "Information") {
            DetailRow(label: "ID", value: container.configuration.id)
            DetailRow(label: "Image", value: container.imageReference)
            DetailRow(label: "Platform", value: "\(container.configuration.platform.os)/\(container.configuration.platform.architecture)")
            DetailRow(label: "Runtime", value: container.configuration.runtimeHandler)
            DetailRow(label: "Working Dir", value: container.configuration.initProcess.workingDirectory)
            if container.configuration.rosetta {
                DetailRow(label: "Rosetta", value: "Enabled")
            }
            if container.configuration.readOnly {
                DetailRow(label: "Read Only", value: "Yes")
            }
        }
    }

    @ViewBuilder
    private func resourcesSection(_ container: ContainerSummary) -> some View {
        DetailSection(title: "Resources") {
            DetailRow(label: "CPUs", value: "\(container.configuration.resources.cpus)")
            DetailRow(label: "Memory", value: container.configuration.resources.memoryInBytes.formattedBytes)
        }
    }

    @ViewBuilder
    private func mountsSection(_ container: ContainerSummary) -> some View {
        DetailSection(title: "Mounts") {
            ForEach(Array(container.configuration.mounts.enumerated()), id: \.offset) { _, mount in
                VStack(alignment: .leading, spacing: 2) {
                    Text(mount.destination)
                        .font(.body.monospaced())
                    HStack {
                        Text(mount.type.displayName)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        if !mount.source.isEmpty {
                            Text(mount.source)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder
    private func portsSection(_ container: ContainerSummary) -> some View {
        DetailSection(title: "Published Ports") {
            ForEach(Array(container.configuration.publishedPorts.enumerated()), id: \.offset) { _, port in
                if let containerPort = port.containerPort, let hostPort = port.hostPort {
                    DetailRow(
                        label: "\(hostPort)",
                        value: "\(containerPort)\(port.portProtocol.map { "/\($0)" } ?? "")"
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func environmentSection(_ container: ContainerSummary) -> some View {
        DetailSection(title: "Environment Variables") {
            ForEach(container.configuration.initProcess.environment, id: \.self) { env in
                Text(env)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
            }
        }
    }

    @ViewBuilder
    private func labelsSection(_ container: ContainerSummary) -> some View {
        DetailSection(title: "Labels") {
            ForEach(Array(container.configuration.labels.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                DetailRow(label: key, value: value)
            }
        }
    }
}

// MARK: - Helper Views

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .trailing)
            Text(value)
                .textSelection(.enabled)
                .font(.body.monospaced())
            Spacer()
        }
        .font(.callout)
    }
}
