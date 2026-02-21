import Foundation

@Observable
@MainActor
final class VolumeListViewModel {
    var volumes: [VolumeSummary] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let service: VolumeService
    private var pollTask: Task<Void, Never>?

    init(service: VolumeService) {
        self.service = service
    }

    var filteredVolumes: [VolumeSummary] {
        volumes.filter { volume in
            searchText.isEmpty
                || volume.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func refresh() async {
        isLoading = volumes.isEmpty
        do {
            volumes = try await service.list()
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
