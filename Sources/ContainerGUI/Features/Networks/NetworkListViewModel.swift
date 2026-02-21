import Foundation

@Observable
@MainActor
final class NetworkListViewModel {
    var networks: [NetworkSummary] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let service: NetworkService
    private var pollTask: Task<Void, Never>?

    init(service: NetworkService) {
        self.service = service
    }

    var filteredNetworks: [NetworkSummary] {
        networks.filter { network in
            searchText.isEmpty
                || network.id.localizedCaseInsensitiveContains(searchText)
                || network.mode.localizedCaseInsensitiveContains(searchText)
        }
    }

    func refresh() async {
        isLoading = networks.isEmpty
        do {
            networks = try await service.list()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                try? await Task.sleep(for: .seconds(10))
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }
}
