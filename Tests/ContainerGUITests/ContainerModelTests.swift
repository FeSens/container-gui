import Foundation
import Testing
@testable import ContainerGUI

@Suite("Container Model Tests")
struct ContainerModelTests {

    @Test("Decodes container list JSON")
    func decodesContainerList() throws {
        let json = """
        [
            {
                "configuration": {
                    "id": "test-container",
                    "image": {
                        "reference": "docker.io/library/nginx:latest",
                        "descriptor": {
                            "mediaType": "application/vnd.oci.image.index.v1+json",
                            "digest": "sha256:abc123",
                            "size": 1234
                        }
                    },
                    "resources": { "cpus": 2, "memoryInBytes": 2147483648 },
                    "platform": { "os": "linux", "architecture": "arm64", "variant": "v8" },
                    "mounts": [],
                    "publishedPorts": [],
                    "labels": {},
                    "networks": [],
                    "initProcess": {
                        "executable": "/usr/sbin/nginx",
                        "arguments": [],
                        "environment": ["PATH=/usr/bin"],
                        "workingDirectory": "/",
                        "user": { "id": { "uid": 0, "gid": 0 } },
                        "terminal": false,
                        "rlimits": [],
                        "supplementalGroups": []
                    },
                    "rosetta": true,
                    "readOnly": false,
                    "ssh": false,
                    "virtualization": false,
                    "runtimeHandler": "container-runtime-linux",
                    "dns": { "nameservers": [], "searchDomains": [], "options": [] },
                    "sysctls": {}
                },
                "status": "running",
                "networks": []
            }
        ]
        """.data(using: .utf8)!

        let containers = try JSONDecoder().decode([ContainerSummary].self, from: json)
        #expect(containers.count == 1)
        #expect(containers[0].id == "test-container")
        #expect(containers[0].isRunning)
        #expect(!containers[0].isStopped)
        #expect(containers[0].imageReference == "docker.io/library/nginx:latest")
        #expect(containers[0].configuration.resources.cpus == 2)
        #expect(containers[0].configuration.resources.memoryInBytes == 2147483648)
    }

    @Test("Short ID returns first 12 characters")
    func shortID() throws {
        let json = """
        [{
            "configuration": {
                "id": "abcdefghijklmnop",
                "image": { "reference": "test", "descriptor": { "mediaType": "m", "digest": "d", "size": 0 } },
                "resources": { "cpus": 1, "memoryInBytes": 1024 },
                "platform": { "os": "linux", "architecture": "arm64" },
                "mounts": [], "publishedPorts": [], "labels": {}, "networks": [],
                "initProcess": {
                    "executable": "/bin/sh", "arguments": [], "environment": [],
                    "workingDirectory": "/", "user": { "id": { "uid": 0, "gid": 0 } },
                    "terminal": false, "rlimits": [], "supplementalGroups": []
                },
                "rosetta": false, "readOnly": false, "ssh": false, "virtualization": false,
                "runtimeHandler": "r", "sysctls": {}
            },
            "status": "stopped", "networks": []
        }]
        """.data(using: .utf8)!

        let containers = try JSONDecoder().decode([ContainerSummary].self, from: json)
        #expect(containers[0].shortID == "abcdefghijkl")
    }
}
