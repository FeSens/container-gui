import Foundation

@Observable
@MainActor
final class ContainerListViewModel {
    var containers: [ContainerSummary] = []
    var searchText: String = ""
    var showRunningOnly: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    private let service: ContainerService
    private var pollTask: Task<Void, Never>?

    init(service: ContainerService) {
        self.service = service
    }

    var filteredContainers: [ContainerSummary] {
        containers.filter { container in
            let matchesFilter = !showRunningOnly || container.isRunning
            let matchesSearch = searchText.isEmpty
                || container.configuration.id.localizedCaseInsensitiveContains(searchText)
                || container.imageReference.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    func refresh() async {
        isLoading = containers.isEmpty
        do {
            containers = try await service.list()
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
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }
}
