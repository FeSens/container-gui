import SwiftUI

struct ImageListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ImageListViewModel?

    var body: some View {
        @Bindable var appState = appState

        Group {
            if let viewModel {
                if viewModel.isLoading && viewModel.images.isEmpty {
                    ProgressView("Loading images...")
                } else if let error = viewModel.errorMessage, viewModel.images.isEmpty {
                    EmptyStateView(
                        title: "Error",
                        description: error,
                        systemImage: "exclamationmark.triangle"
                    )
                } else if viewModel.filteredImages.isEmpty {
                    if viewModel.images.isEmpty {
                        EmptyStateView(
                            title: "No Images",
                            description: "No images found. Pull an image to get started.",
                            systemImage: "opticaldisc"
                        )
                    } else {
                        EmptyStateView(
                            title: "No Results",
                            description: "No images match your search.",
                            systemImage: "magnifyingglass"
                        )
                    }
                } else {
                    List(viewModel.filteredImages, selection: $appState.selectedImageRef) { image in
                        ImageRowView(image: image)
                            .tag(image.id)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .searchable(text: searchText, prompt: "Search images")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    viewModel?.showPullSheet = true
                } label: {
                    Label("Pull", systemImage: "arrow.down.circle")
                }
                .help("Pull an image")

                Button {
                    Task { await viewModel?.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        .sheet(isPresented: pullSheetPresented) {
            PullImageSheet(service: appState.imageService) {
                Task { await viewModel?.refresh() }
            }
        }
        .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 450)
        .task {
            let vm = ImageListViewModel(service: appState.imageService)
            viewModel = vm
            vm.startPolling()
        }
        .onDisappear {
            viewModel?.stopPolling()
        }
        .onChange(of: appState.refreshTrigger) {
            Task { await viewModel?.refresh() }
        }
    }

    private var searchText: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }

    private var pullSheetPresented: Binding<Bool> {
        Binding(
            get: { viewModel?.showPullSheet ?? false },
            set: { viewModel?.showPullSheet = $0 }
        )
    }
}
