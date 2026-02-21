import SwiftUI

struct ImageDetailView: View {
    let imageRef: String
    @Environment(AppState.self) private var appState
    @State private var viewModel: ImageDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.inspectResult == nil {
                    ProgressView("Loading...")
                } else if let inspect = viewModel.inspectResult {
                    imageDetail(inspect, viewModel: viewModel)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    EmptyStateView(
                        title: "Image Not Found",
                        description: "The image may have been deleted.",
                        systemImage: "opticaldisc"
                    )
                }
            } else {
                ProgressView()
            }
        }
        .task(id: imageRef) {
            let vm = ImageDetailViewModel(service: appState.imageService)
            viewModel = vm
            await vm.load(reference: imageRef)
        }
        .alert("Delete Image?", isPresented: deleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel?.delete(reference: imageRef)
                    appState.selectedImageRef = nil
                    appState.requestRefresh()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. The image will be permanently removed.")
        }
    }

    private var deleteConfirmation: Binding<Bool> {
        Binding(
            get: { viewModel?.showDeleteConfirmation ?? false },
            set: { viewModel?.showDeleteConfirmation = $0 }
        )
    }

    @ViewBuilder
    private func imageDetail(_ inspect: ImageInspect, viewModel: ImageDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(inspect, viewModel: viewModel)
                Divider()
                infoSection(inspect)

                if let variant = inspect.variants?.first {
                    if let config = variant.config?.config {
                        Divider()
                        configSection(config)
                    }
                    if let platform = variant.platform {
                        Divider()
                        platformSection(platform)
                    }
                    if let history = variant.config?.history, !history.isEmpty {
                        Divider()
                        historySection(history)
                    }
                    if let size = variant.size {
                        Divider()
                        DetailSection(title: "Size") {
                            DetailRow(label: "Unpacked", value: size.formattedBytes)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(imageRef)
    }

    @ViewBuilder
    private func headerSection(_ inspect: ImageInspect, viewModel: ImageDetailViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(imageRef)
                    .font(.title2.bold())
                if let digest = inspect.index?.digest {
                    Text(digest.prefix(19))
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(role: .destructive) {
                viewModel.showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(viewModel.actionInProgress)
        }
    }

    @ViewBuilder
    private func infoSection(_ inspect: ImageInspect) -> some View {
        DetailSection(title: "Information") {
            DetailRow(label: "Reference", value: inspect.name ?? imageRef)
            if let digest = inspect.index?.digest {
                DetailRow(label: "Digest", value: digest)
            }
        }
    }

    @ViewBuilder
    private func configSection(_ config: ImageOCIConfig) -> some View {
        DetailSection(title: "Configuration") {
            if let entrypoint = config.Entrypoint, !entrypoint.isEmpty {
                DetailRow(label: "Entrypoint", value: entrypoint.joined(separator: " "))
            }
            if let cmd = config.Cmd, !cmd.isEmpty {
                DetailRow(label: "Cmd", value: cmd.joined(separator: " "))
            }
            if let workDir = config.WorkingDir, !workDir.isEmpty {
                DetailRow(label: "Working Dir", value: workDir)
            }
            if let user = config.User, !user.isEmpty {
                DetailRow(label: "User", value: user)
            }
            if let env = config.Env, !env.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Environment")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                    ForEach(env, id: \.self) { entry in
                        Text(entry)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                    }
                }
            }
            if let ports = config.ExposedPorts, !ports.isEmpty {
                DetailRow(label: "Exposed Ports", value: ports.keys.sorted().joined(separator: ", "))
            }
        }
    }

    @ViewBuilder
    private func platformSection(_ platform: ImageVariantPlatform) -> some View {
        DetailSection(title: "Platform") {
            if let os = platform.os {
                DetailRow(label: "OS", value: os)
            }
            if let arch = platform.architecture {
                DetailRow(label: "Architecture", value: arch)
            }
            if let variant = platform.variant {
                DetailRow(label: "Variant", value: variant)
            }
        }
    }

    @ViewBuilder
    private func historySection(_ history: [ImageHistoryEntry]) -> some View {
        DetailSection(title: "History") {
            ForEach(Array(history.enumerated()), id: \.offset) { _, entry in
                VStack(alignment: .leading, spacing: 2) {
                    if let createdBy = entry.createdBy, !createdBy.isEmpty {
                        Text(createdBy)
                            .font(.caption.monospaced())
                            .lineLimit(3)
                            .textSelection(.enabled)
                    }
                    if let created = entry.created {
                        Text(created)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
