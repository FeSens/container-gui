import Foundation

// MARK: - Image List Response

struct ImageSummary: Codable, Identifiable, Sendable {
    var id: String { reference }
    let reference: String
    let descriptor: ImageDescriptor
    let fullSize: String?

    var shortDigest: String {
        let digest = descriptor.digest
        let stripped = digest.hasPrefix("sha256:") ? String(digest.dropFirst(7)) : digest
        return String(stripped.prefix(12))
    }

    var repo: String {
        let parts = reference.split(separator: ":", maxSplits: 1)
        return String(parts.first ?? Substring(reference))
    }

    var tag: String {
        let parts = reference.split(separator: ":", maxSplits: 1)
        return parts.count > 1 ? String(parts[1]) : "latest"
    }
}

// MARK: - Image Inspect Response (CLI returns an array)

struct ImageInspect: Codable, Sendable {
    let name: String?
    let index: ImageDescriptor?
    let variants: [ImageVariant]?
}

struct ImageVariant: Codable, Sendable {
    let platform: ImageVariantPlatform?
    let config: ImageVariantConfig?
    let size: Int?
}

struct ImageVariantPlatform: Codable, Sendable {
    let os: String?
    let architecture: String?
    let variant: String?

    var displayName: String {
        [os, architecture, variant].compactMap { $0 }.joined(separator: "/")
    }
}

struct ImageVariantConfig: Codable, Sendable {
    let os: String?
    let architecture: String?
    let variant: String?
    let config: ImageOCIConfig?
    let history: [ImageHistoryEntry]?
    let created: String?
}

struct ImageOCIConfig: Codable, Sendable {
    let Env: [String]?
    let Cmd: [String]?
    let Entrypoint: [String]?
    let WorkingDir: String?
    let ExposedPorts: [String: EmptyObject]?
    let Labels: [String: String]?
    let User: String?
}

struct ImageHistoryEntry: Codable, Sendable {
    let created: String?
    let createdBy: String?
    let emptyLayer: Bool?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case created
        case createdBy = "created_by"
        case emptyLayer = "empty_layer"
        case comment
    }
}
