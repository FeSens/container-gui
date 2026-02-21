import Foundation
import Testing
@testable import ContainerGUI

@Suite("Image Model Tests")
struct ImageModelTests {

    @Test("Decodes image list JSON from CLI")
    func decodesImageList() throws {
        let json = """
        [
            {
                "descriptor": {
                    "size": 10365,
                    "digest": "sha256:486b8092bfb12997e10d4920897213a06563449c951c5506c2a2cfaf591c599f",
                    "mediaType": "application/vnd.oci.image.index.v1+json"
                },
                "fullSize": "43.6 MB",
                "reference": "docker.io/library/python:slim"
            }
        ]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([ImageSummary].self, from: json)
        #expect(images.count == 1)
        #expect(images[0].reference == "docker.io/library/python:slim")
        #expect(images[0].fullSize == "43.6 MB")
        #expect(images[0].descriptor.size == 10365)
    }

    @Test("Short digest strips sha256 prefix and truncates")
    func shortDigest() throws {
        let json = """
        [{
            "descriptor": { "size": 100, "digest": "sha256:abcdef1234567890abcdef1234567890", "mediaType": "m" },
            "reference": "test:latest"
        }]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([ImageSummary].self, from: json)
        #expect(images[0].shortDigest == "abcdef123456")
    }

    @Test("Repo extracts name without tag")
    func repo() throws {
        let json = """
        [{
            "descriptor": { "size": 0, "digest": "sha256:abc", "mediaType": "m" },
            "reference": "docker.io/library/nginx:latest"
        }]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([ImageSummary].self, from: json)
        #expect(images[0].repo == "docker.io/library/nginx")
    }

    @Test("Tag extracts tag from reference")
    func tag() throws {
        let json = """
        [{
            "descriptor": { "size": 0, "digest": "sha256:abc", "mediaType": "m" },
            "reference": "docker.io/library/nginx:1.25"
        }]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([ImageSummary].self, from: json)
        #expect(images[0].tag == "1.25")
    }

    @Test("Tag defaults to latest when no tag")
    func tagDefaultsToLatest() throws {
        let json = """
        [{
            "descriptor": { "size": 0, "digest": "sha256:abc", "mediaType": "m" },
            "reference": "docker.io/library/nginx"
        }]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([ImageSummary].self, from: json)
        #expect(images[0].tag == "latest")
    }

    @Test("ID uses reference")
    func idUsesReference() throws {
        let json = """
        [{
            "descriptor": { "size": 0, "digest": "sha256:abc", "mediaType": "m" },
            "reference": "my-image:v1"
        }]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([ImageSummary].self, from: json)
        #expect(images[0].id == "my-image:v1")
    }

    @Test("Decodes image inspect JSON with nested OCI config")
    func decodesImageInspect() throws {
        let json = """
        [{
            "name": "docker.io/library/python:slim",
            "index": {
                "mediaType": "application/vnd.oci.image.index.v1+json",
                "digest": "sha256:486b8092bf",
                "size": 10365
            },
            "variants": [{
                "platform": { "os": "linux", "architecture": "arm64", "variant": "v8" },
                "config": {
                    "os": "linux",
                    "architecture": "arm64",
                    "variant": "v8",
                    "config": {
                        "Env": ["PATH=/usr/bin", "PYTHON_VERSION=3.14"],
                        "Cmd": ["python3"],
                        "Entrypoint": ["/entrypoint.sh"],
                        "WorkingDir": "/app",
                        "User": "root"
                    },
                    "history": [
                        {
                            "created": "2026-02-02T00:00:00Z",
                            "created_by": "ADD file:abc in /",
                            "comment": "debuerreotype"
                        },
                        {
                            "created": "2026-02-04T20:04:34Z",
                            "created_by": "CMD [\\"python3\\"]",
                            "empty_layer": true
                        }
                    ],
                    "created": "2026-02-04T20:10:13Z"
                },
                "size": 43572044
            }]
        }]
        """.data(using: .utf8)!

        let inspects = try JSONDecoder().decode([ImageInspect].self, from: json)
        let inspect = try #require(inspects.first)
        #expect(inspect.name == "docker.io/library/python:slim")
        #expect(inspect.index?.digest == "sha256:486b8092bf")

        let variant = try #require(inspect.variants?.first)
        #expect(variant.platform?.os == "linux")
        #expect(variant.platform?.architecture == "arm64")
        #expect(variant.platform?.displayName == "linux/arm64/v8")
        #expect(variant.size == 43572044)

        let config = try #require(variant.config?.config)
        #expect(config.Env?.count == 2)
        #expect(config.Cmd == ["python3"])
        #expect(config.Entrypoint == ["/entrypoint.sh"])
        #expect(config.WorkingDir == "/app")

        let history = try #require(variant.config?.history)
        #expect(history.count == 2)
        #expect(history[0].comment == "debuerreotype")
        #expect(history[1].emptyLayer == true)
    }
}
