import Foundation

actor SystemService {
    private let cli: CLIService

    init(cli: CLIService) {
        self.cli = cli
    }

    func diskUsage() async throws -> SystemDiskUsage {
        try await cli.execute(SystemDiskUsage.self, arguments: ["system", "df", "--format", "json"])
    }

    func status() async throws -> String {
        try await cli.executeRaw(arguments: ["system", "status"])
    }

    func start() async throws {
        try await cli.executeAction(arguments: ["system", "start"])
    }

    func stop() async throws {
        try await cli.executeAction(arguments: ["system", "stop"])
    }
}
