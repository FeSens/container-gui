import Foundation

actor BuilderService {
    private let cli: CLIService

    init(cli: CLIService) {
        self.cli = cli
    }

    func status() async throws -> BuilderStatus? {
        let output = try await cli.executeRaw(arguments: ["builder", "status"])
        return BuilderStatus.parse(output)
    }

    func start() async throws {
        try await cli.executeAction(arguments: ["builder", "start"])
    }

    func stop() async throws {
        try await cli.executeAction(arguments: ["builder", "stop"])
    }

    func delete() async throws {
        try await cli.executeAction(arguments: ["builder", "delete"])
    }
}
