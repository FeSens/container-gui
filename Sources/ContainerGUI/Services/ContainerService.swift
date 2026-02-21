import Foundation

actor ContainerService {
    private let cli: CLIService

    init(cli: CLIService) {
        self.cli = cli
    }

    func list() async throws -> [ContainerSummary] {
        try await cli.execute([ContainerSummary].self, arguments: ["list", "--format", "json"])
    }

    func inspect(id: String) async throws -> [ContainerSummary] {
        try await cli.execute([ContainerSummary].self, arguments: ["inspect", id])
    }

    func start(id: String) async throws {
        try await cli.executeAction(arguments: ["start", id])
    }

    func stop(id: String) async throws {
        try await cli.executeAction(arguments: ["stop", id])
    }

    func kill(id: String) async throws {
        try await cli.executeAction(arguments: ["kill", id])
    }

    func delete(id: String) async throws {
        try await cli.executeAction(arguments: ["delete", id])
    }

    func prune() async throws {
        try await cli.executeAction(arguments: ["prune"])
    }

    func logs(id: String, follow: Bool = false, tail: Int? = nil) async throws -> AsyncThrowingStream<String, Error> {
        var args = ["logs"]
        if let tail { args += ["-n", "\(tail)"] }
        if follow { args.append("--follow") }
        args.append(id)
        return try await cli.stream(arguments: args)
    }
}
