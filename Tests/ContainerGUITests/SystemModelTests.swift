import Foundation
import Testing
@testable import ContainerGUI

@Suite("System Model Tests")
struct SystemModelTests {

    @Test("Decodes system disk usage JSON")
    func decodesSystemDiskUsage() throws {
        let json = """
        {
          "containers": {"active": 1, "reclaimable": 486342656, "sizeInBytes": 889475072, "total": 2},
          "images": {"active": 2, "reclaimable": 156602368, "sizeInBytes": 700477440, "total": 3},
          "volumes": {"active": 0, "reclaimable": 0, "sizeInBytes": 0, "total": 0}
        }
        """.data(using: .utf8)!

        let usage = try JSONDecoder().decode(SystemDiskUsage.self, from: json)

        #expect(usage.containers.active == 1)
        #expect(usage.containers.reclaimable == 486342656)
        #expect(usage.containers.sizeInBytes == 889475072)
        #expect(usage.containers.total == 2)

        #expect(usage.images.active == 2)
        #expect(usage.images.reclaimable == 156602368)
        #expect(usage.images.sizeInBytes == 700477440)
        #expect(usage.images.total == 3)

        #expect(usage.volumes.active == 0)
        #expect(usage.volumes.reclaimable == 0)
        #expect(usage.volumes.sizeInBytes == 0)
        #expect(usage.volumes.total == 0)
    }

    @Test("Decodes disk usage entry with all fields")
    func decodesDiskUsageEntry() throws {
        let json = """
        {"active": 5, "reclaimable": 1024, "sizeInBytes": 2048, "total": 10}
        """.data(using: .utf8)!

        let entry = try JSONDecoder().decode(DiskUsageEntry.self, from: json)
        #expect(entry.active == 5)
        #expect(entry.reclaimable == 1024)
        #expect(entry.sizeInBytes == 2048)
        #expect(entry.total == 10)
    }
}
