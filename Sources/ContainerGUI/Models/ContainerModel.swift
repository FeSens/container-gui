import Foundation

// MARK: - Container List Response

struct ContainerSummary: Codable, Identifiable, Sendable {
    var id: String { configuration.id }
    let configuration: ContainerConfiguration
    let status: String
    let networks: [ContainerNetworkStatus]
}

// MARK: - Configuration

struct ContainerConfiguration: Codable, Sendable {
    let id: String
    let image: ContainerImage
    let resources: ContainerResources
    let platform: ContainerPlatform
    let mounts: [ContainerMount]
    let publishedPorts: [ContainerPublishedPort]
    let labels: [String: String]
    let networks: [ContainerNetworkConfig]
    let initProcess: ContainerInitProcess
    let rosetta: Bool
    let readOnly: Bool
    let ssh: Bool
    let virtualization: Bool
    let runtimeHandler: String
    let dns: ContainerDNS?
    let sysctls: [String: String]
    let publishedSockets: [ContainerPublishedSocket]?
}

// MARK: - Image Reference

struct ContainerImage: Codable, Sendable {
    let reference: String
    let descriptor: ImageDescriptor
}

struct ImageDescriptor: Codable, Sendable {
    let mediaType: String
    let digest: String
    let size: Int
}

// MARK: - Resources

struct ContainerResources: Codable, Sendable {
    let cpus: Int
    let memoryInBytes: Int
}

// MARK: - Platform

struct ContainerPlatform: Codable, Sendable {
    let os: String
    let architecture: String
    let variant: String?
}

// MARK: - Mount

struct ContainerMount: Codable, Sendable {
    let source: String
    let destination: String
    let options: [String]
    let type: ContainerMountType
}

struct ContainerMountType: Codable, Sendable {
    let tmpfs: EmptyObject?
    let virtiofs: EmptyObject?
    let bind: EmptyObject?

    var displayName: String {
        if tmpfs != nil { return "tmpfs" }
        if virtiofs != nil { return "virtiofs" }
        if bind != nil { return "bind" }
        return "unknown"
    }
}

struct EmptyObject: Codable, Sendable {}

// MARK: - Published Port

struct ContainerPublishedPort: Codable, Sendable {
    let containerPort: Int?
    let hostPort: Int?
    let hostAddress: String?
    let portProtocol: String?

    enum CodingKeys: String, CodingKey {
        case containerPort, hostPort, hostAddress
        case portProtocol = "protocol"
    }
}

// MARK: - Published Socket

struct ContainerPublishedSocket: Codable, Sendable {
    let containerPath: String?
    let hostPath: String?
}

// MARK: - Network

struct ContainerNetworkConfig: Codable, Sendable {
    let network: String
    let options: ContainerNetworkOptions?
}

struct ContainerNetworkOptions: Codable, Sendable {
    let hostname: String?
}

struct ContainerNetworkStatus: Codable, Sendable {
    let network: String?
    let ipAddress: String?
}

// MARK: - Init Process

struct ContainerInitProcess: Codable, Sendable {
    let executable: String
    let arguments: [String]
    let environment: [String]
    let workingDirectory: String
    let user: ContainerUser
    let terminal: Bool
    let rlimits: [ContainerRlimit]
    let supplementalGroups: [Int]
}

struct ContainerUser: Codable, Sendable {
    let id: ContainerUserID
}

struct ContainerUserID: Codable, Sendable {
    let uid: Int
    let gid: Int
}

struct ContainerRlimit: Codable, Sendable {
    let type: String?
    let soft: Int?
    let hard: Int?
}

// MARK: - DNS

struct ContainerDNS: Codable, Sendable {
    let nameservers: [String]
    let searchDomains: [String]
    let options: [String]
}

// MARK: - Status Helpers

extension ContainerSummary {
    var isRunning: Bool {
        status.lowercased() == "running"
    }

    var isStopped: Bool {
        status.lowercased() == "stopped"
    }

    var imageReference: String {
        configuration.image.reference
    }

    var shortID: String {
        String(configuration.id.prefix(12))
    }
}
