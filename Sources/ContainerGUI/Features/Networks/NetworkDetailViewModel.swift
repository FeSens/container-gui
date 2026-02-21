import Foundation

@Observable
@MainActor
final class NetworkDetailViewModel {
    var network: NetworkSummary?
    var isLoading: Bool = false
    var errorMessage: String?
    var actionInProgress: Bool = false
    var showDeleteConfirmation: Bool = false

    private let service: NetworkService

    init(service: NetworkService) {
        self.service = service
    }

    func load(id: String) async {
        isLoading = true
        do {
            network = try await service.inspect(id: id)
            errorMessage = nil
        } catch {
            network = nil
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func delete(id: String) async {
        actionInProgress = true
        do {
            try await service.delete(id: id)
            network = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        actionInProgress = false
    }
}
