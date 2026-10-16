
import SwiftUI
import AVFoundation

struct ClipTrimmerView: View {
    let url: URL
    let onTrim: (Double, Double) -> Void

    @State private var assetDuration: Double = 0
    @State private var trimStart: Double = 0
    @State private var trimEnd: Double = 0
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let minimumDuration = 0.1

    private var selectedDuration: Double {
        max(0, trimEnd - trimStart)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("TRIM CLIP")
                .font(.system(size: 13, weight: .bold))
                .tracking(1)

            if isLoading {
                ProgressView("Loading video…")
                    .frame(maxWidth: .infinity)
            } else if assetDuration > 0 {
                VideoPreview(url: url)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text(timeString(trimStart))
                            .monospacedDigit()
                    }
                    .font(.system(size: 12))

                    Slider(
                        value: $trimStart,
                        in: 0...max(0, assetDuration - minimumDuration)
                    )
                    .tint(.blue)
                    .onChange(of: trimStart) { _, newValue in
                        if trimEnd < newValue + minimumDuration {
                            trimEnd = min(
                                assetDuration,
                                newValue + minimumDuration
                            )
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("End")
                        Spacer()
                        Text(timeString(trimEnd))
                            .monospacedDigit()
                    }
                    .font(.system(size: 12))

                    Slider(
                        value: $trimEnd,
                        in: min(assetDuration, trimStart + minimumDuration)...max(
                            min(assetDuration, trimStart + minimumDuration),
                            assetDuration
                        )
                    )
                    .tint(.blue)
                }

                HStack {
                    Text("Selected duration")
                    Spacer()
                    Text(timeString(selectedDuration))
                        .monospacedDigit()
                }
                .font(.system(size: 12, weight: .medium))

                Button {
                    onTrim(trimStart, selectedDuration)
                } label: {
                    Text("Apply Trim")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .task(id: url) {
            await loadDuration()
        }
    }

    @MainActor
    private func loadDuration() async {
        isLoading = true
        errorMessage = nil

        do {
            let asset = AVURLAsset(url: url)
            let duration = try await asset.load(.duration)
            let seconds = CMTimeGetSeconds(duration)

            guard seconds.isFinite, seconds > 0 else {
                throw NSError(
                    domain: "Kinetiq",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "This video has an invalid duration."
                    ]
                )
            }

            assetDuration = seconds
            trimStart = 0
            trimEnd = seconds
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func timeString(_ seconds: Double) -> String {
        let safeSeconds = max(0, Int(seconds))
        let minutes = safeSeconds / 60
        let remainingSeconds = safeSeconds % 60

        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
