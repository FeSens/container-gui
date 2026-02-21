import Foundation

struct SystemDiskUsage: Codable, Sendable {
    let containers: DiskUsageEntry
    let images: DiskUsageEntry
    let volumes: DiskUsageEntry
}

struct DiskUsageEntry: Codable, Sendable {
    let active: Int
    let reclaimable: Int
    let sizeInBytes: Int
    let total: Int
}
