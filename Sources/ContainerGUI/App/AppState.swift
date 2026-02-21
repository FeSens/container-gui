import SwiftUI

@Observable
@MainActor
final class AppState {
    var selectedCategory: SidebarCategory = .containers
    var selectedContainerID: String?
    var selectedImageRef: String?
    var selectedNetworkID: String?
    var selectedVolumeName: String?
    var cliAvailable: Bool = false
    var errorMessage: String?
    var refreshTrigger: Int = 0

    @ObservationIgnored private(set) var cli: CLIService
    @ObservationIgnored private(set) var containerService: ContainerService
    @ObservationIgnored private(set) var imageService: ImageService
    @ObservationIgnored private(set) var networkService: NetworkService
    @ObservationIgnored private(set) var volumeService: VolumeService
    @ObservationIgnored private(set) var builderService: BuilderService
    @ObservationIgnored private(set) var systemService: SystemService

    init() {
        let cli = CLIService(containerPath: "/opt/homebrew/bin/container")
        self.cli = cli
        self.containerService = ContainerService(cli: cli)
        self.imageService = ImageService(cli: cli)
        self.networkService = NetworkService(cli: cli)
        self.volumeService = VolumeService(cli: cli)
        self.builderService = BuilderService(cli: cli)
        self.systemService = SystemService(cli: cli)
    }

    func setup() async {
        let detectedCLI = await CLIService()
        self.cli = detectedCLI
        self.containerService = ContainerService(cli: detectedCLI)
        self.imageService = ImageService(cli: detectedCLI)
        self.networkService = NetworkService(cli: detectedCLI)
        self.volumeService = VolumeService(cli: detectedCLI)
        self.builderService = BuilderService(cli: detectedCLI)
        self.systemService = SystemService(cli: detectedCLI)
        self.cliAvailable = await detectedCLI.isAvailable
    }

    func requestRefresh() {
        refreshTrigger += 1
    }
}
