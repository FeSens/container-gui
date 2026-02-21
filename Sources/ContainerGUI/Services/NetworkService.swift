import Foundation

actor NetworkService {
    private let cli: CLIService

    init(cli: CLIService) {
        self.cli = cli
    }

    func list() async throws -> [NetworkSummary] {
        try await cli.execute([NetworkSummary].self, arguments: ["network", "list", "--format", "json"])
    }

    func inspect(id: String) async throws -> NetworkSummary? {
        let results = try await cli.execute([NetworkSummary].self, arguments: ["network", "inspect", id])
        return results.first
    }

    func create(name: String) async throws {
        try await cli.executeAction(arguments: ["network", "create", name])
    }

    func delete(id: String) async throws {
        try await cli.executeAction(arguments: ["network", "delete", id])
    }

    func prune() async throws {
        try await cli.executeAction(arguments: ["network", "prune"])
    }
}
