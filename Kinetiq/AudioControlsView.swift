
import SwiftUI
import AVFoundation

struct AudioControlsView: View {
    @Binding var volume: Double
    @Binding var isMuted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
                    .frame(width: 28)

                Text("Audio")
                    .font(.system(size: 15, weight: .semibold))

                Spacer()

                Toggle("Mute", isOn: $isMuted)
                    .labelsHidden()
                    .tint(.blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Volume")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(volume * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .monospacedDigit()
                }

                Slider(value: $volume, in: 0...1)
                    .tint(.blue)
                    .disabled(isMuted)
            }

            HStack(spacing: 8) {
                Image(systemName: "waveform")
                    .foregroundStyle(.secondary)

                Text(isMuted ? "Audio muted" : "Audio enabled")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
