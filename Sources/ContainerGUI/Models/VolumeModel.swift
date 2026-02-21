import Foundation

// MARK: - Volume List Response

struct VolumeSummary: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let driver: String?
    let format: String?
    let source: String?
    let sizeInBytes: Int?
    let createdAt: Double?
    let labels: [String: String]?
    let options: [String: String]?

    var createdDate: Date? {
        guard let createdAt else { return nil }
        return Date(timeIntervalSinceReferenceDate: createdAt)
    }

    var formattedSize: String? {
        guard let sizeInBytes else { return nil }
        return sizeInBytes.formattedBytes
    }
}

// MARK: - Volume Inspect Response (CLI returns an array)

struct VolumeInspect: Codable, Sendable {
    let name: String
    let driver: String?
    let format: String?
    let source: String?
    let sizeInBytes: Int?
    let createdAt: String?
    let labels: [String: String]?
    let options: [String: String]?

    var createdDate: Date? {
        guard let createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }

    var formattedSize: String? {
        guard let sizeInBytes else { return nil }
        return sizeInBytes.formattedBytes
    }
}
