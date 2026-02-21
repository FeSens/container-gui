import SwiftUI

struct NetworkRowView: View {
    let network: NetworkSummary

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(network.id)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(network.mode)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    if let state = network.state {
                        StatusBadge(status: state)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }
}
