import Foundation
import Testing
@testable import ContainerGUI

@Suite("Volume Model Tests")
struct VolumeModelTests {

    @Test("Decodes volume list JSON from CLI")
    func decodesVolumeList() throws {
        let json = """
        [{"source":"/path/to/volume.img","format":"ext4","createdAt":793393203.665526,"driver":"local","options":{},"labels":{},"sizeInBytes":549755813888,"name":"test-vol"}]
        """.data(using: .utf8)!

        let volumes = try JSONDecoder().decode([VolumeSummary].self, from: json)
        #expect(volumes.count == 1)
        #expect(volumes[0].name == "test-vol")
        #expect(volumes[0].driver == "local")
        #expect(volumes[0].format == "ext4")
        #expect(volumes[0].source == "/path/to/volume.img")
        #expect(volumes[0].sizeInBytes == 549755813888)
        #expect(volumes[0].createdAt == 793393203.665526)
    }

    @Test("Decodes volume inspect JSON from CLI")
    func decodesVolumeInspect() throws {
        let json = """
        [{"createdAt":"2026-02-21T19:00:03Z","driver":"local","format":"ext4","labels":{},"name":"test-vol","options":{},"sizeInBytes":549755813888,"source":"/path/to/volume.img"}]
        """.data(using: .utf8)!

        let inspects = try JSONDecoder().decode([VolumeInspect].self, from: json)
        let inspect = try #require(inspects.first)
        #expect(inspect.name == "test-vol")
        #expect(inspect.driver == "local")
        #expect(inspect.format == "ext4")
        #expect(inspect.source == "/path/to/volume.img")
        #expect(inspect.sizeInBytes == 549755813888)
        #expect(inspect.createdAt == "2026-02-21T19:00:03Z")
    }

    @Test("ID uses name for VolumeSummary")
    func idUsesName() throws {
        let json = """
        [{"name":"my-volume","source":"/path","format":"ext4","createdAt":100.0,"driver":"local","options":{},"labels":{},"sizeInBytes":1024}]
        """.data(using: .utf8)!

        let volumes = try JSONDecoder().decode([VolumeSummary].self, from: json)
        #expect(volumes[0].id == "my-volume")
    }

    @Test("Handles empty labels and options in volume list")
    func handlesEmptyLabelsAndOptionsList() throws {
        let json = """
        [{"name":"empty-vol","source":"/path","format":"ext4","createdAt":100.0,"driver":"local","options":{},"labels":{},"sizeInBytes":0}]
        """.data(using: .utf8)!

        let volumes = try JSONDecoder().decode([VolumeSummary].self, from: json)
        #expect(volumes[0].labels?.isEmpty == true)
        #expect(volumes[0].options?.isEmpty == true)
    }

    @Test("Handles empty labels and options in volume inspect")
    func handlesEmptyLabelsAndOptionsInspect() throws {
        let json = """
        [{"createdAt":"2026-02-21T19:00:03Z","driver":"local","format":"ext4","labels":{},"name":"empty-vol","options":{},"sizeInBytes":0,"source":"/path"}]
        """.data(using: .utf8)!

        let inspects = try JSONDecoder().decode([VolumeInspect].self, from: json)
        let inspect = try #require(inspects.first)
        #expect(inspect.labels?.isEmpty == true)
        #expect(inspect.options?.isEmpty == true)
    }

    @Test("VolumeSummary createdAt converts to Date via timeIntervalSinceReferenceDate")
    func volumeSummaryCreatedDate() throws {
        let json = """
        [{"name":"date-vol","source":"/path","format":"ext4","createdAt":793393203.665526,"driver":"local","options":{},"labels":{},"sizeInBytes":1024}]
        """.data(using: .utf8)!

        let volumes = try JSONDecoder().decode([VolumeSummary].self, from: json)
        let date = try #require(volumes[0].createdDate)
        let expected = Date(timeIntervalSinceReferenceDate: 793393203.665526)
        #expect(date == expected)
    }

    @Test("VolumeInspect createdAt converts ISO8601 string to Date")
    func volumeInspectCreatedDate() throws {
        let json = """
        [{"createdAt":"2026-02-21T19:00:03Z","driver":"local","format":"ext4","labels":{},"name":"date-vol","options":{},"sizeInBytes":1024,"source":"/path"}]
        """.data(using: .utf8)!

        let inspects = try JSONDecoder().decode([VolumeInspect].self, from: json)
        let inspect = try #require(inspects.first)
        let date = try #require(inspect.createdDate)
        let formatter = ISO8601DateFormatter()
        let expected = try #require(formatter.date(from: "2026-02-21T19:00:03Z"))
        #expect(date == expected)
    }

    @Test("VolumeSummary formattedSize returns human-readable bytes")
    func formattedSize() throws {
        let json = """
        [{"name":"size-vol","source":"/path","format":"ext4","createdAt":100.0,"driver":"local","options":{},"labels":{},"sizeInBytes":549755813888}]
        """.data(using: .utf8)!

        let volumes = try JSONDecoder().decode([VolumeSummary].self, from: json)
        let formatted = try #require(volumes[0].formattedSize)
        #expect(!formatted.isEmpty)
    }
}
