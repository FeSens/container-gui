import SwiftUI

struct ContainerRowView: View {
    let container: ContainerSummary

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(container.configuration.id)
                    .font(.headline)
                    .lineLimit(1)
                Text(container.imageReference)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            StatusBadge(status: container.status)
        }
        .padding(.vertical, 2)
    }
}
