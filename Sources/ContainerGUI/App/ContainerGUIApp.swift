import SwiftUI

@main
struct ContainerGUIApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.cliAvailable {
                    CLINotFoundView()
                } else {
                    ContentView()
                }
            }
            .environment(appState)
            .task {
                await appState.setup()
            }
        }
        .defaultSize(width: 1100, height: 700)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Refresh") {
                    NotificationCenter.default.post(name: .refreshRequested, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let refreshRequested = Notification.Name("refreshRequested")
}

struct CLINotFoundView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Container CLI Not Found")
                .font(.title2.bold())
            Text("The 'container' command-line tool was not found on your system.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Link("Install from GitHub",
                 destination: URL(string: "https://github.com/apple/container")!)
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}
