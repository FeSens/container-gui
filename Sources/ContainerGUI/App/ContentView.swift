import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    private var isSinglePaneCategory: Bool {
        appState.selectedCategory == .builder || appState.selectedCategory == .system
    }

    var body: some View {
        @Bindable var appState = appState

        NavigationSplitView {
            SidebarView()
        } detail: {
            if isSinglePaneCategory {
                singlePaneContent
            } else {
                HStack(spacing: 0) {
                    listContent
                        .frame(minWidth: 280, idealWidth: 350, maxWidth: 450)
                    Divider()
                    detailContent
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private var singlePaneContent: some View {
        switch appState.selectedCategory {
        case .builder:
            BuilderView()
        case .system:
            SystemView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var listContent: some View {
        switch appState.selectedCategory {
        case .containers:
            ContainerListView()
        case .images:
            ImageListView()
        case .volumes:
            VolumeListView()
        case .networks:
            NetworkListView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch appState.selectedCategory {
        case .containers:
            if let containerID = appState.selectedContainerID {
                ContainerDetailView(containerID: containerID)
            } else {
                EmptyStateView(
                    title: "No Container Selected",
                    description: "Select a container to view its details.",
                    systemImage: "shippingbox"
                )
            }
        case .images:
            if let imageRef = appState.selectedImageRef {
                ImageDetailView(imageRef: imageRef)
            } else {
                EmptyStateView(
                    title: "No Image Selected",
                    description: "Select an image to view its details.",
                    systemImage: "opticaldisc"
                )
            }
        case .volumes:
            if let volumeName = appState.selectedVolumeName {
                VolumeDetailView(volumeName: volumeName)
            } else {
                EmptyStateView(
                    title: "No Volume Selected",
                    description: "Select a volume to view its details.",
                    systemImage: "externaldrive"
                )
            }
        case .networks:
            if let networkID = appState.selectedNetworkID {
                NetworkDetailView(networkID: networkID)
            } else {
                EmptyStateView(
                    title: "No Network Selected",
                    description: "Select a network to view its details.",
                    systemImage: "network"
                )
            }
        default:
            EmptyView()
        }
    }
}
