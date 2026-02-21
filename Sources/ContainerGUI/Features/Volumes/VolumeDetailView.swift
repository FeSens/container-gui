import SwiftUI

struct VolumeDetailView: View {
    let volumeName: String
    @Environment(AppState.self) private var appState
    @State private var viewModel: VolumeDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.inspectResult == nil {
                    ProgressView("Loading...")
                } else if let inspect = viewModel.inspectResult {
                    volumeDetail(inspect, viewModel: viewModel)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    EmptyStateView(
                        title: "Volume Not Found",
                        description: "The volume may have been deleted.",
                        systemImage: "externaldrive"
                    )
                }
            } else {
                ProgressView()
            }
        }
        .task(id: volumeName) {
            let vm = VolumeDetailViewModel(service: appState.volumeService)
            viewModel = vm
            await vm.load(name: volumeName)
        }
        .alert("Delete Volume?", isPresented: deleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel?.delete(name: volumeName)
                    appState.selectedVolumeName = nil
                    appState.requestRefresh()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. The volume will be permanently removed.")
        }
    }

    private var deleteConfirmation: Binding<Bool> {
        Binding(
            get: { viewModel?.showDeleteConfirmation ?? false },
            set: { viewModel?.showDeleteConfirmation = $0 }
        )
    }

    @ViewBuilder
    private func volumeDetail(_ inspect: VolumeInspect, viewModel: VolumeDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(inspect, viewModel: viewModel)
                Divider()
                infoSection(inspect)
                if let labels = inspect.labels, !labels.isEmpty {
                    Divider()
                    labelsSection(labels)
                }
            }
            .padding()
        }
        .navigationTitle(volumeName)
    }

    @ViewBuilder
    private func headerSection(_ inspect: VolumeInspect, viewModel: VolumeDetailViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(inspect.name)
                    .font(.title2.bold())
                if let driver = inspect.driver {
                    Text(driver)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            HStack(spacing: 8) {
                if viewModel.actionInProgress {
                    ProgressView()
                        .controlSize(.small)
                }
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(viewModel.actionInProgress)
            }
        }
    }

    @ViewBuilder
    private func infoSection(_ inspect: VolumeInspect) -> some View {
        DetailSection(title: "Information") {
            DetailRow(label: "Name", value: inspect.name)
            if let driver = inspect.driver {
                DetailRow(label: "Driver", value: driver)
            }
            if let format = inspect.format {
                DetailRow(label: "Format", value: format)
            }
            if let source = inspect.source {
                DetailRow(label: "Source", value: source)
            }
            if let sizeInBytes = inspect.sizeInBytes {
                DetailRow(label: "Size", value: sizeInBytes.formattedBytes)
            }
            if let createdDate = inspect.createdDate {
                DetailRow(label: "Created", value: createdDate.formatted(.dateTime))
            }
        }
    }

    @ViewBuilder
    private func labelsSection(_ labels: [String: String]) -> some View {
        DetailSection(title: "Labels") {
            ForEach(Array(labels.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                DetailRow(label: key, value: value)
            }
        }
    }
}
