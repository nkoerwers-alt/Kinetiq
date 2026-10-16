
import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var selectedTool = "Select"
    @State private var selectedTrack = "Main Video"
    @State private var playhead: Double = 0.25
    @State private var zoom: Double = 1

    private let background = Color(red: 0.035, green: 0.035, blue: 0.045)
    private let panel = Color(red: 0.075, green: 0.075, blue: 0.09)
    private let accent = Color(red: 0.35, green: 0.72, blue: 1)

    private let tools: [(String, String)] = [
        ("Select", "cursorarrow"),
        ("Cut", "scissors"),
        ("Audio", "waveform"),
        ("Text", "textformat"),
        ("Effects", "sparkles"),
        ("Speed", "speedometer"),
        ("Media", "photo.on.rectangle")
    ]

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width < 700

            VStack(spacing: 0) {
                header

                Divider().overlay(.white.opacity(0.08))

                if compact {
                    compactEditor
                } else {
                    desktopEditor
                }

                Divider().overlay(.white.opacity(0.08))
                timeline
            }
            .background(background)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(accent)

            Text("KINETIQ")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .tracking(2)

            Text("EDITOR")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))

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
                .background(accent.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)

            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 36, height: 36)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var compactEditor: some View {
        VStack(spacing: 12) {
            PreviewPlaceholder(isPlaying: isPlaying)
                .padding(.horizontal, 12)
                .padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tools, id: \.0) { tool in
                        Button {
                            selectedTool = tool.0
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: tool.1)
                                Text(tool.0)
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(
                                selectedTool == tool.0 ? accent : .white.opacity(0.65)
                            )
                            .frame(width: 62, height: 58)
                            .background(
                                selectedTool == tool.0
                                    ? accent.opacity(0.12) : panel
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }

            inspector
            Spacer(minLength: 0)
        }
    }

    private var desktopEditor: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                ForEach(tools, id: \.0) { tool in
                    EditorToolButton(
                        title: tool.0,
                        symbol: tool.1,
                        isSelected: selectedTool == tool.0
                    ) {
                        selectedTool = tool.0
                    }
                }

                Spacer()
            }
            .frame(width: 82)
            .padding(.top, 12)

            Divider().overlay(.white.opacity(0.08))

            VStack(spacing: 12) {
                PreviewPlaceholder(isPlaying: isPlaying)
                    .frame(maxWidth: 760)

                HStack {
                    Text("00:\(String(format: "%02d", Int(playhead * 60)))")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.65))

                    Spacer()

                    Text("16:9  •  1080p")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: 760)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().overlay(.white.opacity(0.08))

            inspector
                .frame(width: 220)
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedTool == "Select" ? "Inspector" : selectedTool.uppercased())
                .font(.system(size: 13, weight: .bold))
                .tracking(0.7)

            Divider().overlay(.white.opacity(0.08))

            Text("SELECTED CLIP")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.4))

            Text(selectedTrack)
                .font(.system(size: 13, weight: .medium))

            if selectedTool == "Speed" {
                Text("Playback speed")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))

                Text("\(zoom.formatted(.number.precision(.fractionLength(1))))×")
                    .font(.system(size: 20, weight: .semibold))

                Slider(value: $zoom, in: 0.25...3, step: 0.25)
                    .tint(accent)
            } else {
                Text("Position")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))

                HStack {
                    Text("00:00")
                    Spacer()
                    Text("00:10")
                }
                .font(.system(size: 11, design: .monospaced))

                Text("Clip settings")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))

                Button {
                    selectedTool = "Effects"
                } label: {
                    Label("Add effect", systemImage: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(panel)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(panel.opacity(0.5))
    }

    private var timeline: some View {
        VStack(spacing: 10) {
            HStack {
                Text("TIMELINE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)

                Spacer()

                Button {
                    playhead = max(0, playhead - 0.05)
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                }
                .buttonStyle(.plain)

                Slider(value: $zoom, in: 0.5...2)
                    .tint(accent)
                    .frame(width: 85)

                Button {
                    playhead = min(1, playhead + 0.05)
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                }
                .buttonStyle(.plain)
            }

            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 3) {
                        ForEach([
                            ("Main Video", "film", Color.blue),
                            ("Overlay", "square.on.square", Color.purple),
                            ("Audio", "waveform", Color.green),
                            ("Title", "textformat", Color.orange)
                        ], id: \.0) { track in
                            HStack(spacing: 8) {
                                Text(track.0)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.65))
                                    .frame(width: 76, alignment: .leading)

                                Button {
                                    selectedTrack = track.0
                                } label: {
                                    TimelineClipView(
                                        title: track.0,
                                        color: track.2,
                                        isSelected: selectedTrack == track.0
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(height: 42)
                        }
                    }

                    Rectangle()
                        .fill(accent)
                        .frame(width: 2)
                        .offset(x: 86 + (geometry.size.width - 90) * playhead)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 177)
            .clipped()
        }
        .padding(12)
        .frame(height: 235)
        .background(panel)
    }
}
