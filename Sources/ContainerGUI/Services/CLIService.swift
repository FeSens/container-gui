import Foundation

actor CLIService {
    private let containerPath: String?

    init() async {
        self.containerPath = await CLIService.findContainerPath()
    }

    init(containerPath: String) {
        self.containerPath = containerPath
    }

    var isAvailable: Bool {
        containerPath != nil
    }

    var resolvedPath: String {
        get throws {
            guard let path = containerPath else {
                throw CLIError.cliNotFound
            }
            return path
        }
    }

    // MARK: - Execute and decode JSON

    func execute<T: Decodable & Sendable>(_ type: T.Type, arguments: [String], timeout: Duration = .seconds(30)) async throws -> T {
        let output = try await run(arguments: arguments, timeout: timeout)
        let data = Data(output.utf8)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CLIError.decodingFailed(output: output, underlying: error)
        }
    }

    // MARK: - Execute and return raw text

    func executeRaw(arguments: [String], timeout: Duration = .seconds(30)) async throws -> String {
        try await run(arguments: arguments, timeout: timeout)
    }

    // MARK: - Execute action (check exit code only)

    func executeAction(arguments: [String], timeout: Duration = .seconds(30)) async throws {
        _ = try await run(arguments: arguments, timeout: timeout)
    }

    // MARK: - Stream output

    func stream(arguments: [String]) throws -> AsyncThrowingStream<String, Error> {
        let path = try resolvedPath

        return AsyncThrowingStream { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = arguments

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice

            let lineBuffer = LineBuffer()

            pipe.fileHandleForReading.readabilityHandler = { @Sendable handle in
                let data = handle.availableData
                if data.isEmpty {
                    if let remaining = lineBuffer.flush() {
                        continuation.yield(remaining)
                    }
                    handle.readabilityHandler = nil
                    return
                }
                guard let chunk = String(data: data, encoding: .utf8) else { return }
                let lines = lineBuffer.append(chunk)
                for line in lines {
                    continuation.yield(line)
                }
            }

            process.terminationHandler = { @Sendable proc in
                pipe.fileHandleForReading.readabilityHandler = nil
                if let remaining = lineBuffer.flush() {
                    continuation.yield(remaining)
                }
                if proc.terminationStatus != 0 {
                    continuation.finish(throwing: CLIError.nonZeroExit(Int(proc.terminationStatus)))
                } else {
                    continuation.finish()
                }
            }

            continuation.onTermination = { @Sendable _ in
                if process.isRunning {
                    process.terminate()
                }
            }

            do {
                try process.run()
            } catch {
                continuation.finish(throwing: CLIError.executionFailed(error.localizedDescription))
            }
        }
    }

    // MARK: - Private

    private func run(arguments: [String], timeout: Duration) async throws -> String {
        let path = try resolvedPath

        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: path)
                process.arguments = arguments

                let stdoutPipe = Pipe()
                let stderrPipe = Pipe()
                process.standardOutput = stdoutPipe
                process.standardError = stderrPipe

                try process.run()
                process.waitUntilExit()

                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

                guard process.terminationStatus == 0 else {
                    let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""
                    throw CLIError.nonZeroExit(Int(process.terminationStatus), message: errorOutput)
                }

                return String(data: stdoutData, encoding: .utf8) ?? ""
            }

            group.addTask {
                try await Task.sleep(for: timeout)
                throw CLIError.timeout
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private static func findContainerPath() async -> String? {
        let knownPaths = [
            "/opt/homebrew/bin/container",
            "/usr/local/bin/container",
        ]

        for path in knownPaths {
            if FileManager.default.isExecutableFile(atPath: path) {
                return path
            }
        }

        // Fallback: try `which`
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["container"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !path.isEmpty
                {
                    return path
                }
            }
        } catch {
            // Ignore
        }

        return nil
    }
}

// MARK: - Line Buffer

private final class LineBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var buffer = ""

    func append(_ chunk: String) -> [String] {
        lock.lock()
        defer { lock.unlock() }
        buffer += chunk
        var lines: [String] = []
        while let range = buffer.range(of: "\n") {
            let line = String(buffer[buffer.startIndex..<range.lowerBound])
            if !line.isEmpty {
                lines.append(line)
            }
            buffer = String(buffer[range.upperBound...])
        }
        return lines
    }

    func flush() -> String? {
        lock.lock()
        defer { lock.unlock() }
        guard !buffer.isEmpty else { return nil }
        let remaining = buffer
        buffer = ""
        return remaining
    }
}

// MARK: - Errors

enum CLIError: LocalizedError, Sendable {
    case cliNotFound
    case executionFailed(String)
    case nonZeroExit(Int, message: String = "")
    case decodingFailed(output: String, underlying: Error)
    case timeout

    var errorDescription: String? {
        switch self {
        case .cliNotFound:
            "The 'container' CLI was not found. Install it from github.com/apple/container."
        case .executionFailed(let msg):
            "Failed to execute command: \(msg)"
        case .nonZeroExit(let code, let message):
            "Command exited with code \(code)\(message.isEmpty ? "" : ": \(message)")"
        case .decodingFailed(let output, let underlying):
            "Failed to decode output: \(underlying.localizedDescription)\nOutput: \(output.prefix(200))"
        case .timeout:
            "Command timed out"
        }
    }
}
