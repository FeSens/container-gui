import Foundation

@Observable
@MainActor
final class ContainerDetailViewModel {
    var container: ContainerSummary?
    var isLoading: Bool = false
    var errorMessage: String?
    var actionInProgress: Bool = false
    var showDeleteConfirmation: Bool = false

    private let service: ContainerService

    init(service: ContainerService) {
        self.service = service
    }

    func load(id: String) async {
        isLoading = true
        do {
            let results = try await service.inspect(id: id)
            container = results.first
            errorMessage = nil
        } catch {
            container = nil
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func start() async {
        await performAction { [self] id in
            try await service.start(id: id)
        }
    }

    func stop() async {
        await performAction { [self] id in
            try await service.stop(id: id)
        }
    }

    func kill() async {
        await performAction { [self] id in
            try await service.kill(id: id)
        }
    }

    func delete() async {
        guard let id = container?.id else { return }
        actionInProgress = true
        do {
            try await service.delete(id: id)
            container = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        actionInProgress = false
    }

    private func performAction(_ action: (String) async throws -> Void) async {
        guard let id = container?.id else { return }
        let previousStatus = container?.status
        actionInProgress = true
        do {
            try await action(id)
        } catch {
            errorMessage = error.localizedDescription
            actionInProgress = false
            return
        }
        // Poll until status changes or container is gone (--rm)
        for _ in 0..<10 {
            do {
                let results = try await service.inspect(id: id)
                if let updated = results.first {
                    if updated.status != previousStatus {
                        container = updated
                        errorMessage = nil
                        actionInProgress = false
                        return
                    }
                } else {
                    // Container gone (--rm)
                    container = nil
                    errorMessage = nil
                    actionInProgress = false
                    return
                }
            } catch {
                container = nil
                errorMessage = nil
                actionInProgress = false
                return
            }
            try? await Task.sleep(for: .milliseconds(300))
        }
        // Fallback: reload whatever state we have
        do {
            let results = try await service.inspect(id: id)
            container = results.first
            errorMessage = nil
        } catch {
            container = nil
            errorMessage = nil
        }
        actionInProgress = false
    }
}
