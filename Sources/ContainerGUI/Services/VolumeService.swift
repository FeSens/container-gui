import Foundation

actor VolumeService {
    private let cli: CLIService

    init(cli: CLIService) {
        self.cli = cli
    }

    func list() async throws -> [VolumeSummary] {
        try await cli.execute([VolumeSummary].self, arguments: ["volume", "list", "--format", "json"])
    }

    func inspect(name: String) async throws -> VolumeInspect? {
        let results = try await cli.execute([VolumeInspect].self, arguments: ["volume", "inspect", name])
        return results.first
    }

    func create(name: String) async throws {
        try await cli.executeAction(arguments: ["volume", "create", name])
    }

    func delete(name: String) async throws {
        try await cli.executeAction(arguments: ["volume", "delete", name])
    }

    func prune() async throws {
        try await cli.executeAction(arguments: ["volume", "prune"])
    }
}
