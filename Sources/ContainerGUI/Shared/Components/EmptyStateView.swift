import SwiftUI

struct EmptyStateView: View {
    let title: String
    let description: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
    }
}
