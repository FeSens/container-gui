import SwiftUI

struct ImageRowView: View {
    let image: ImageSummary

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(image.reference)
                    .font(.headline)
                    .lineLimit(1)
                if !image.shortDigest.isEmpty {
                    Text(image.shortDigest)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let fullSize = image.fullSize {
                Text(fullSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
