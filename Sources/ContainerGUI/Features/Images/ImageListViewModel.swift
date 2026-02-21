import Foundation

@Observable
@MainActor
final class ImageListViewModel {
    var images: [ImageSummary] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showPullSheet: Bool = false

    private let service: ImageService
    private var pollTask: Task<Void, Never>?

    init(service: ImageService) {
        self.service = service
    }

    var filteredImages: [ImageSummary] {
        images.filter { image in
            searchText.isEmpty
                || image.reference.localizedCaseInsensitiveContains(searchText)
                || image.shortDigest.localizedCaseInsensitiveContains(searchText)
        }
    }

    func refresh() async {
        isLoading = images.isEmpty
        do {
            images = try await service.list()
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
