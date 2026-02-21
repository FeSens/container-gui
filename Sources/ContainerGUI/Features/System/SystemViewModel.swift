import Foundation

@Observable
@MainActor
final class SystemViewModel {
    var diskUsage: SystemDiskUsage?
    var statusText: String?
    var isLoading: Bool = false
    var errorMessage: String?
    var actionInProgress: Bool = false

    private let service: SystemService

    init(service: SystemService) {
        self.service = service
    }

    func refresh() async {
        isLoading = diskUsage == nil && statusText == nil
        do {
            async let fetchedStatus = service.status()
            async let fetchedDiskUsage = service.diskUsage()
            statusText = try await fetchedStatus
            diskUsage = try await fetchedDiskUsage
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func startServices() async {
        actionInProgress = true
        do {
            try await service.start()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        await refresh()
        actionInProgress = false
    }

    func stopServices() async {
        actionInProgress = true
        do {
            try await service.stop()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        await refresh()
        actionInProgress = false
    }
}
