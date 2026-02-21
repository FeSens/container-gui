import SwiftUI

struct PullImageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PullImageViewModel
    let onComplete: () -> Void

    init(service: ImageService, onComplete: @escaping () -> Void) {
        self._viewModel = State(initialValue: PullImageViewModel(service: service))
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Pull Image")
                .font(.headline)

            HStack {
                TextField("Image reference (e.g. docker.io/library/nginx:latest)", text: $viewModel.reference)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.pull() }
                    .disabled(viewModel.isPulling)

                if viewModel.isPulling {
                    Button("Cancel") {
                        viewModel.cancel()
                    }
                } else {
                    Button("Pull") {
                        viewModel.pull()
                    }
                    .disabled(viewModel.reference.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            if !viewModel.output.isEmpty || viewModel.isPulling {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(viewModel.output.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(.caption.monospaced())
                                    .textSelection(.enabled)
                                    .id(index)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                    }
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(minHeight: 150, maxHeight: 300)
                    .onChange(of: viewModel.output.count) { _, _ in
                        if let last = viewModel.output.indices.last {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button("Done") {
                    viewModel.cancel()
                    onComplete()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}
