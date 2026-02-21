import Foundation

@Observable
@MainActor
final class PullImageViewModel {
    var reference: String = ""
    var output: [String] = []
    var isPulling: Bool = false
    var errorMessage: String?

    private let service: ImageService
    private var pullTask: Task<Void, Never>?

    init(service: ImageService) {
        self.service = service
    }

    func pull() {
        guard !reference.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isPulling = true
        errorMessage = nil
        output = []

        pullTask?.cancel()
        pullTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await service.pull(reference: reference)
                for try await line in stream {
                    self.output.append(line)
                }
            } catch is CancellationError {
                // Cancelled
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isPulling = false
        }
    }

    func cancel() {
        pullTask?.cancel()
        pullTask = nil
        isPulling = false
    }
}
