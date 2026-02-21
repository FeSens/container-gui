import Foundation

// MARK: - Network List / Inspect Response

struct NetworkSummary: Codable, Identifiable, Sendable {
    let id: String
    let state: String?
    let config: NetworkConfig?
    let status: NetworkStatus?
}

// MARK: - Network Config

struct NetworkConfig: Codable, Sendable {
    let id: String?
    let creationDate: Double?
    let mode: String?
    let labels: [String: String]?
}

// MARK: - Network Status

struct NetworkStatus: Codable, Sendable {
    let ipv4Subnet: String?
    let ipv4Gateway: String?
    let ipv6Subnet: String?
}

// MARK: - Computed Helpers

extension NetworkSummary {
    var isRunning: Bool {
        state?.lowercased() == "running"
    }

    var mode: String {
        config?.mode ?? "unknown"
    }
}
