
import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct ExportView: View {
    let sourceURL: URL
    var startTime: Double = 0
    var duration: Double? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var errorMessage: String?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 30))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export Video")
                            .font(.system(size: 20, weight: .bold))

                        Text(sourceURL.lastPathComponent)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("EXPORT SETTINGS")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    settingRow(
                        title: "Quality",
                        value: "Highest available"
                    )

                    settingRow(
                        title: "Format",
                        value: "MP4"
                    )

                    settingRow(
                        title: "Trim start",
                        value: timeString(startTime)
                    )

                    if let duration {
                        settingRow(
                            title: "Duration",
                            value: timeString(duration)
                        )
                    }
                }

                Spacer()

                if isExporting {
                    ProgressView("Exporting video…")
                        .frame(maxWidth: .infinity)
                }

                if let exportedURL {
                    Label("Export completed", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Save or Share Video", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)
                } else {
                    Button {
                        exportVideo()
                    } label: {
                        Label("Start Export", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)
                }

                Text("Export time depends on the video's length and resolution.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert(
                "Export Error",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(isPresented: $showShareSheet) {
                if let exportedURL {
                    ShareSheet(items: [exportedURL])
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func settingRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .font(.system(size: 13))
    }

    private func exportVideo() {
        isExporting = true
        errorMessage = nil

        VideoExporter.exportVideo(
            from: sourceURL,
            startTime: startTime,
            duration: duration
        ) { result in
            isExporting = false

            switch result {
            case .success(let url):
                exportedURL = url

            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let total = max(0, Int(seconds))
        return String(
            format: "%02d:%02d",
            total / 60,
            total % 60
        )
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ controller: UIActivityViewController,
        context: Context
    ) {}
}
