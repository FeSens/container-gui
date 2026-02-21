import SwiftUI

struct StatusBadge: View {
    let status: String

    private var color: Color {
        switch status.lowercased() {
        case "running": .green
        case "stopped": .red
        case "paused": .yellow
        case "created": .blue
        default: .secondary
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(status.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
