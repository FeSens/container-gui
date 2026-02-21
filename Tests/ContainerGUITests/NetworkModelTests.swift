import Foundation
import Testing
@testable import ContainerGUI

@Suite("Network Model Tests")
struct NetworkModelTests {

    @Test("Decodes network list JSON from CLI")
    func decodesNetworkList() throws {
        let json = """
        [
            {
                "state": "running",
                "id": "default",
                "config": {
                    "id": "default",
                    "creationDate": 793388309.686895,
                    "mode": "nat",
                    "labels": {
                        "com.apple.container.resource.role": "builtin"
                    }
                },
                "status": {
                    "ipv4Subnet": "192.168.64.0/24",
                    "ipv4Gateway": "192.168.64.1",
                    "ipv6Subnet": "fdad:f502:8822:d019::/64"
                }
            }
        ]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        #expect(networks.count == 1)
        #expect(networks[0].id == "default")
        #expect(networks[0].state == "running")
        #expect(networks[0].config?.mode == "nat")
        #expect(networks[0].config?.creationDate == 793388309.686895)
        #expect(networks[0].config?.labels?["com.apple.container.resource.role"] == "builtin")
        #expect(networks[0].status?.ipv4Subnet == "192.168.64.0/24")
        #expect(networks[0].status?.ipv4Gateway == "192.168.64.1")
        #expect(networks[0].status?.ipv6Subnet == "fdad:f502:8822:d019::/64")
    }

    @Test("isRunning returns true when state is running")
    func isRunningTrue() throws {
        let json = """
        [{"id": "net1", "state": "running"}]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        #expect(networks[0].isRunning)
    }

    @Test("isRunning returns false when state is not running")
    func isRunningFalse() throws {
        let json = """
        [{"id": "net1", "state": "stopped"}]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        #expect(!networks[0].isRunning)
    }

    @Test("isRunning returns false when state is nil")
    func isRunningNilState() throws {
        let json = """
        [{"id": "net1"}]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        #expect(!networks[0].isRunning)
    }

    @Test("mode returns config mode when present")
    func modeFromConfig() throws {
        let json = """
        [{"id": "net1", "config": {"mode": "nat"}}]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        #expect(networks[0].mode == "nat")
    }

    @Test("mode returns unknown when config is nil")
    func modeDefaultsToUnknown() throws {
        let json = """
        [{"id": "net1"}]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        #expect(networks[0].mode == "unknown")
    }

    @Test("NetworkStatus fields decode correctly")
    func networkStatusFields() throws {
        let json = """
        [{
            "id": "test-net",
            "status": {
                "ipv4Subnet": "10.0.0.0/16",
                "ipv4Gateway": "10.0.0.1",
                "ipv6Subnet": "fd00::/64"
            }
        }]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        let status = try #require(networks[0].status)
        #expect(status.ipv4Subnet == "10.0.0.0/16")
        #expect(status.ipv4Gateway == "10.0.0.1")
        #expect(status.ipv6Subnet == "fd00::/64")
    }

    @Test("NetworkStatus handles nil fields")
    func networkStatusNilFields() throws {
        let json = """
        [{"id": "net1", "status": {}}]
        """.data(using: .utf8)!

        let networks = try JSONDecoder().decode([NetworkSummary].self, from: json)
        let status = try #require(networks[0].status)
        #expect(status.ipv4Subnet == nil)
        #expect(status.ipv4Gateway == nil)
        #expect(status.ipv6Subnet == nil)
    }
}
