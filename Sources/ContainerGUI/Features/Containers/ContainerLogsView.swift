import SwiftUI

struct ContainerLogsView: View {
    let containerID: String
    @Environment(AppState.self) private var appState
    @State private var logText: String = ""
    @State private var autoScroll: Bool = true
    @State private var streamTask: Task<Void, Never>?
    @State private var isStreaming: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            logToolbar
            Divider()
            if logText.isEmpty && !isStreaming {
                EmptyStateView(
                    title: "No Logs",
                    description: "Start streaming to view container logs.",
                    systemImage: "text.alignleft"
                )
            } else if logText.isEmpty && isStreaming {
                VStack {
                    ProgressView("Waiting for output...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LogTextView(text: logText, autoScroll: autoScroll)
            }
        }
        .onAppear {
            startStreaming()
        }
        .onDisappear {
            stopStreaming()
        }
    }

    @ViewBuilder
    private var logToolbar: some View {
        HStack(spacing: 8) {
            if isStreaming {
                Button {
                    stopStreaming()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                }
                .help("Stop streaming")
            } else {
                Button {
                    startStreaming()
                } label: {
                    Label("Stream", systemImage: "play.fill")
                }
                .help("Start streaming logs")
            }

            Button {
                logText = ""
            } label: {
                Label("Clear", systemImage: "trash")
            }
            .help("Clear log output")

            Spacer()

            Toggle(isOn: $autoScroll) {
                Label("Auto-scroll", systemImage: "arrow.down.to.line")
            }
            .toggleStyle(.button)
            .help("Auto-scroll to bottom")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private func startStreaming() {
        stopStreaming()
        logText = ""
        isStreaming = true

        streamTask = Task {
            do {
                let stream = try await appState.containerService.logs(
                    id: containerID, follow: true, tail: 200
                )
                for try await line in stream {
                    if Task.isCancelled { break }
                    logText += line + "\n"
                }
            } catch is CancellationError {
                // Expected
            } catch {
                logText += "\n[Error: \(error.localizedDescription)]\n"
            }
            isStreaming = false
        }
    }

    private func stopStreaming() {
        streamTask?.cancel()
        streamTask = nil
        isStreaming = false
    }
}
