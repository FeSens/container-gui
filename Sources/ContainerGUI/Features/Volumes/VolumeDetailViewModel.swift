import Foundation

@Observable
@MainActor
final class VolumeDetailViewModel {
    var inspectResult: VolumeInspect?
    var isLoading: Bool = false
    var errorMessage: String?
    var actionInProgress: Bool = false
    var showDeleteConfirmation: Bool = false

    private let service: VolumeService

    init(service: VolumeService) {
        self.service = service
    }

    func load(name: String) async {
        isLoading = true
        do {
            inspectResult = try await service.inspect(name: name)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func delete(name: String) async {
        actionInProgress = true
        do {
            try await service.delete(name: name)
            inspectResult = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        actionInProgress = false
    }
}
