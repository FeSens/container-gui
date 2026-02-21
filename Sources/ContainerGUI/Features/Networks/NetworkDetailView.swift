import SwiftUI

struct NetworkDetailView: View {
    let networkID: String
    @Environment(AppState.self) private var appState
    @State private var viewModel: NetworkDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.network == nil {
                    ProgressView("Loading...")
                } else if let network = viewModel.network {
                    networkDetail(network, viewModel: viewModel)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else {
                    EmptyStateView(
                        title: "Network Not Found",
                        description: "The network may have been deleted.",
                        systemImage: "network"
                    )
                }
            } else {
                ProgressView()
            }
        }
        .task(id: networkID) {
            let vm = NetworkDetailViewModel(service: appState.networkService)
            viewModel = vm
            await vm.load(id: networkID)
        }
        .alert("Delete Network?", isPresented: deleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel?.delete(id: networkID)
                    appState.selectedNetworkID = nil
                    appState.requestRefresh()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. The network will be permanently removed.")
        }
    }

    private var deleteConfirmation: Binding<Bool> {
        Binding(
            get: { viewModel?.showDeleteConfirmation ?? false },
            set: { viewModel?.showDeleteConfirmation = $0 }
        )
    }

    @ViewBuilder
    private func networkDetail(_ network: NetworkSummary, viewModel: NetworkDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection(network, viewModel: viewModel)
                Divider()
                infoSection(network)
                if let status = network.status,
                   (status.ipv4Subnet != nil || status.ipv4Gateway != nil || status.ipv6Subnet != nil)
                {
                    Divider()
                    statusSection(status)
                }
                if let labels = network.config?.labels, !labels.isEmpty {
                    Divider()
                    labelsSection(labels)
                }
            }
            .padding()
        }
        .navigationTitle(network.id)
    }

    @ViewBuilder
    private func headerSection(_ network: NetworkSummary, viewModel: NetworkDetailViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(network.id)
                    .font(.title2.bold())
                if let state = network.state {
                    StatusBadge(status: state)
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
    private func infoSection(_ network: NetworkSummary) -> some View {
        DetailSection(title: "Information") {
            DetailRow(label: "ID", value: network.id)
            DetailRow(label: "Mode", value: network.mode)
            if let state = network.state {
                DetailRow(label: "State", value: state.capitalized)
            }
        }
    }

    @ViewBuilder
    private func statusSection(_ status: NetworkStatus) -> some View {
        DetailSection(title: "Status") {
            if let ipv4Subnet = status.ipv4Subnet {
                DetailRow(label: "IPv4 Subnet", value: ipv4Subnet)
            }
            if let ipv4Gateway = status.ipv4Gateway {
                DetailRow(label: "IPv4 Gateway", value: ipv4Gateway)
            }
            if let ipv6Subnet = status.ipv6Subnet {
                DetailRow(label: "IPv6 Subnet", value: ipv6Subnet)
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
