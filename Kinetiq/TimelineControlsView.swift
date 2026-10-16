
import SwiftUI

struct TimelineControlsView: View {
    @Binding var playhead: Double

    var duration: Double
    var onSplit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("TIMELINE CONTROLS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)

                Spacer()

                Text(timeString(playhead * max(duration, 0)))
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Slider(value: $playhead, in: 0...1)
                .tint(.blue)

            HStack(spacing: 10) {
                Button(action: onSplit) {
                    Label("Split", systemImage: "scissors")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
