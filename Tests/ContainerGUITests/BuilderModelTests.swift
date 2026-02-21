import Foundation
import Testing
@testable import ContainerGUI

@Suite("Builder Model Tests")
struct BuilderModelTests {

    @Test("Parses valid builder status output with stopped state")
    func parsesStoppedBuilder() throws {
        let output = """
        ID        IMAGE                                               STATE    ADDR  CPUS  MEMORY
        buildkit  ghcr.io/apple/container-builder-shim/builder:0.7.0  stopped        2     2048 MB
        """

        let status = try #require(BuilderStatus.parse(output))
        #expect(status.id == "buildkit")
        #expect(status.image == "ghcr.io/apple/container-builder-shim/builder:0.7.0")
        #expect(status.state == "stopped")
        #expect(status.address == "")
        #expect(status.cpus == "2")
        #expect(status.memory == "2048 MB")
        #expect(status.isStopped)
        #expect(!status.isRunning)
    }

    @Test("Parses builder status output with running state and address")
    func parsesRunningBuilder() throws {
        let output = """
        ID        IMAGE                                               STATE    ADDR             CPUS  MEMORY
        buildkit  ghcr.io/apple/container-builder-shim/builder:0.7.0  running  192.168.64.2:80  2     2048 MB
        """

        let status = try #require(BuilderStatus.parse(output))
        #expect(status.id == "buildkit")
        #expect(status.image == "ghcr.io/apple/container-builder-shim/builder:0.7.0")
        #expect(status.state == "running")
        #expect(status.address == "192.168.64.2:80")
        #expect(status.cpus == "2")
        #expect(status.memory == "2048 MB")
        #expect(status.isRunning)
        #expect(!status.isStopped)
    }

    @Test("Returns nil for empty output")
    func parsesEmptyOutput() {
        let status = BuilderStatus.parse("")
        #expect(status == nil)
    }

    @Test("Returns nil for header-only output")
    func parsesHeaderOnly() {
        let output = "ID        IMAGE                                               STATE    ADDR  CPUS  MEMORY"
        let status = BuilderStatus.parse(output)
        #expect(status == nil)
    }

    @Test("Returns nil for invalid output")
    func parsesInvalidOutput() {
        let output = "some random text that is not a table"
        let status = BuilderStatus.parse(output)
        #expect(status == nil)
    }
}
