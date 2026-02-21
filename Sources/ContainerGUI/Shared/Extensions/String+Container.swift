import Foundation

extension String {
    var truncatedID: String {
        String(prefix(12))
    }
}

extension Int {
    var formattedBytes: String {
        ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .memory)
    }
}
