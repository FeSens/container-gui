import Foundation

actor ImageService {
    private let cli: CLIService

    init(cli: CLIService) {
        self.cli = cli
    }

    func list() async throws -> [ImageSummary] {
        try await cli.execute([ImageSummary].self, arguments: ["image", "list", "--format", "json"])
    }

    func inspect(reference: String) async throws -> ImageInspect? {
        let results = try await cli.execute([ImageInspect].self, arguments: ["image", "inspect", reference])
        return results.first
    }

    func delete(reference: String) async throws {
        try await cli.executeAction(arguments: ["image", "delete", reference])
    }

    func pull(reference: String) async throws -> AsyncThrowingStream<String, Error> {
        try await cli.stream(arguments: ["image", "pull", reference])
    }

    func prune() async throws {
        try await cli.executeAction(arguments: ["image", "prune"])
    }

    func tag(source: String, target: String) async throws {
        try await cli.executeAction(arguments: ["image", "tag", source, target])
    }
}
