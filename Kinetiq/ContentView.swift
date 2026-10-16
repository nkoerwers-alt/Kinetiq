
import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var selectedTool = "Select"
    @State private var selectedClip = "Main Video"
    @State private var playhead: CGFloat = 0.28

    private let background = Color(red: 0.035, green: 0.04, blue: 0.05)
    private let panel = Color(red: 0.075, green: 0.08, blue: 0.095)
    private let accent = Color(red: 0.38, green: 0.75, blue: 1.0)

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider().overlay(.white.opacity(0.08))

            HStack(spacing: 0) {
                toolRail

                VStack(spacing: 12) {
                    previewPanel
                    timelinePanel
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                inspector
            }
        }
        .background(background)
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Text("K")
                .font(.system(size: 23, weight: .black))
                .foregroundStyle(accent)

            Text("KINETIQ")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .tracking(2)

            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(width: 1, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("Untitled Project")
                    .font(.system(size: 13, weight: .medium))
                Text("Saved locally")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer()

            Button {
                isPlaying.toggle()
            } label: {
                Label(
                    isPlaying ? "Pause" : "Preview",
                    systemImage: isPlaying ? "pause.fill" : "play.fill"
                )
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(accent, in: RoundedRectangle(cornerRadius: 7))
                .foregroundStyle(.black)
            }
            .buttonStyle(.plain)

            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 36, height: 36)
                    .background(panel, in: RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Export project")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private var toolRail: some View {
        VStack(spacing: 7) {
            toolButton("Select", icon: "cursorarrow")
            toolButton("Cut", icon: "scissors")
            toolButton("Audio", icon: "waveform")
            toolButton("Text", icon: "textformat")
            toolButton("Effects", icon: "sparkles")
            toolButton("Speed", icon: "speedometer")

            Spacer()

            toolButton("Media", icon: "film")
        }
        .padding(9)
        .frame(width: 66)
        .background(panel.opacity(0.7))
    }

    private func toolButton(_ name: String, icon: String) -> some View {
        Button {
            selectedTool = name
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                Text(name)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundStyle(selectedTool == name ? accent : .white.opacity(0.55))
            .frame(width: 52, height: 53)
            .background {
                if selectedTool == name {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accent.opacity(0.12))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var previewPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("VIEWER")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.45))

                Spacer()

                Text("16:9")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))

                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.19, blue: 0.25),
                                Color(red: 0.035, green: 0.05, blue: 0.075),
                                Color(red: 0.16, green: 0.13, blue: 0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 8) {
                    Image(systemName: "play.rectangle")
                        .font(.system(size: 38, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.65))

                    Text("Your preview")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))

                    Text("Import a video to get started")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: 680)

            HStack(spacing: 18) {
                Image(systemName: "backward.end.fill")

                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(accent)
                }
                .buttonStyle(.plain)

                Image(systemName: "forward.end.fill")

                Text("00:00:00")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                Image(systemName: "speaker.wave.2")
                Image(systemName: "gearshape")
            }
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.65))
        }
        .padding(14)
        .background(panel, in: RoundedRectangle(cornerRadius: 10))
    }

    private var timelinePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TIMELINE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Button {
                    playhead = max(0, playhead - 0.05)
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                }
                .buttonStyle(.plain)

                Button {
                    playhead = min(1, playhead + 0.05)
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                }
                .buttonStyle(.plain)

                Image(systemName: "slider.horizontal.3")
            }
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    trackLabel("VIDEO 1", icon: "film")
                    trackLabel("VIDEO 2", icon: "square.stack")
                    trackLabel("AUDIO 1", icon: "waveform")
                    trackLabel("TEXT", icon: "textformat")
                }
                .frame(width: 78)

                GeometryReader { geometry in
                    let width = max(geometry.size.width, 420)

                    VStack(spacing: 6) {
                        HStack {
                            ForEach(
                                ["00:00", "00:05", "00:10", "00:15", "00:20"],
                                id: \.self
                            ) { time in
                                Text(time)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.4))
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(height: 15)

                        timelineClip(
                            title: "Main Video",
                            color: accent,
                            width: width * 0.65,
                            selected: selectedClip == "Main Video"
                        )
                        .onTapGesture {
                            selectedClip = "Main Video"
                        }

                        timelineClip(
                            title: "Overlay",
                            color: .purple,
                            width: width * 0.36,
                            selected: selectedClip == "Overlay"
                        )
                        .onTapGesture {
                            selectedClip = "Overlay"
                        }

                        timelineClip(
                            title: "Audio Track",
                            color: .green,
                            width: width * 0.82,
                            selected: selectedClip == "Audio Track"
                        )
                        .onTapGesture {
                            selectedClip = "Audio Track"
                        }

                        timelineClip(
                            title: "Title",
                            color: .orange,
                            width: width * 0.27,
                            selected: selectedClip == "Title"
                        )
                        .onTapGesture {
                            selectedClip = "Title"
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 1.5)
                            .frame(maxHeight: .infinity)
                            .offset(x: width * playhead, y: 12)
                            .allowsHitTesting(false)
                    }
                }
                .frame(minWidth: 420)
            }
            .frame(height: 126)
            .clipped()

            HStack {
                Label(selectedTool, systemImage: "cursorarrow")
                Spacer()
                Text("Selected: \(selectedClip)")
                    .lineLimit(1)
            }
            .font(.system(size: 10))
            .foregroundStyle(.white.opacity(0.45))
        }
        .padding(14)
        .background(panel, in: RoundedRectangle(cornerRadius: 10))
    }

    private func trackLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .lineLimit(1)
        }
        .foregroundStyle(.white.opacity(0.55))
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 27)
    }

    private func timelineClip(
        title: String,
        color: Color,
        width: CGFloat,
        selected: Bool
    ) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3)

            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .frame(width: max(width, 65), height: 25, alignment: .leading)
        .background(color.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(
                    selected ? color : color.opacity(0.35),
                    lineWidth: selected ? 1.5 : 0.5
                )
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("INSPECTOR")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.45))

            Text(selectedClip)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)

            Divider().overlay(.white.opacity(0.1))

            Text("TRANSFORM")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.45))

            inspectorValue("Position", value: "0, 0")
            inspectorValue("Scale", value: "100%")
            inspectorValue("Rotation", value: "0°")

            Divider().overlay(.white.opacity(0.1))

            Text("OPACITY")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.45))

            Slider(value: .constant(1))
                .tint(accent)

            Spacer(minLength: 0)

            Button {
                selectedTool = "Effects"
            } label: {
                Label("Add Effect", systemImage: "plus")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        .white.opacity(0.07),
                        in: RoundedRectangle(cornerRadius: 6)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 190)
        .background(panel.opacity(0.7))
    }

    private func inspectorValue(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.55))
            Spacer(minLength: 4)
            Text(value)
                .monospacedDigit()
        }
        .font(.system(size: 10))
    }
}
