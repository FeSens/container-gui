import Foundation

@Observable
@MainActor
final class BuilderViewModel {
    var builderStatus: BuilderStatus?
    var isLoading: Bool = false
    var errorMessage: String?
    var actionInProgress: Bool = false

    private let service: BuilderService
    private var pollTask: Task<Void, Never>?

    init(service: BuilderService) {
        self.service = service
    }

    func refresh() async {
        isLoading = builderStatus == nil
        do {
            builderStatus = try await service.status()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func start() async {
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

    func stop() async {
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

    func delete() async {
        actionInProgress = true
        do {
            try await service.delete()
            builderStatus = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        await refresh()
        actionInProgress = false
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
