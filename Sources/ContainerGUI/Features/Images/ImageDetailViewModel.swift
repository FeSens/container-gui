import Foundation

@Observable
@MainActor
final class ImageDetailViewModel {
    var inspectResult: ImageInspect?
    var isLoading: Bool = false
    var errorMessage: String?
    var actionInProgress: Bool = false
    var showDeleteConfirmation: Bool = false

    private let service: ImageService

    init(service: ImageService) {
        self.service = service
    }

    func load(reference: String) async {
        isLoading = true
        do {
            inspectResult = try await service.inspect(reference: reference) ?? nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func delete(reference: String) async {
        actionInProgress = true
        do {
            try await service.delete(reference: reference)
            inspectResult = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        actionInProgress = false
    }
}
