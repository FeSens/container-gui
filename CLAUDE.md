# Container GUI

Native macOS SwiftUI app wrapping Apple's `container` CLI.

## Build & Run

```bash
swift build          # Build the project
swift run ContainerGUI  # Run the app
swift test           # Run tests
```

## Architecture

- **SPM executable** (no .xcodeproj)
- **SwiftUI** with `NavigationSplitView` (3-column layout)
- **MVVM** with `@Observable` macro
- **macOS 15+** (Apple Silicon required)
- **CLI wrapper**: Executes `container` commands via `Foundation.Process`, parses JSON
- **No external dependencies**

## Key Conventions

- Services are `actor` types for thread safety
- ViewModels are `@Observable @MainActor` classes
- AppState is injected via `.environment()`
- All CLI interaction goes through `CLIService`
- Models use `Codable` to decode CLI JSON output
- Use Swift 6 strict concurrency
