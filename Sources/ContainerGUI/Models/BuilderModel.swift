import Foundation

struct BuilderStatus: Sendable {
    let id: String
    let image: String
    let state: String
    let address: String
    let cpus: String
    let memory: String

    var isRunning: Bool {
        state.lowercased() == "running"
    }

    var isStopped: Bool {
        state.lowercased() == "stopped"
    }

    static func parse(_ output: String) -> BuilderStatus? {
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard lines.count >= 2 else { return nil }

        // Skip the header line, parse the data line
        let dataLine = lines[1]

        // Split by 2+ whitespace characters
        let fields = dataLine.components(separatedBy: "  ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Expected fields: ID, IMAGE, STATE, ADDR, CPUS, MEMORY
        // ADDR may be empty, so we need at least 5 fields (without addr) or 6 (with addr)
        guard fields.count >= 5 else { return nil }

        if fields.count >= 6 {
            return BuilderStatus(
                id: fields[0],
                image: fields[1],
                state: fields[2],
                address: fields[3],
                cpus: fields[4],
                memory: fields[5]
            )
        } else {
            // ADDR is empty — fields are: ID, IMAGE, STATE, CPUS, MEMORY
            return BuilderStatus(
                id: fields[0],
                image: fields[1],
                state: fields[2],
                address: "",
                cpus: fields[3],
                memory: fields[4]
            )
        }
    }
}
