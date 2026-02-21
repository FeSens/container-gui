import SwiftUI

enum SidebarCategory: String, CaseIterable, Identifiable, Sendable {
    case containers
    case images
    case volumes
    case networks
    case builder
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .containers: "Containers"
        case .images: "Images"
        case .volumes: "Volumes"
        case .networks: "Networks"
        case .builder: "Builder"
        case .system: "System"
        }
    }

    var icon: String {
        switch self {
        case .containers: "shippingbox"
        case .images: "opticaldisc"
        case .volumes: "externaldrive"
        case .networks: "network"
        case .builder: "hammer"
        case .system: "gear"
        }
    }
}
