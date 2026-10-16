
import SwiftUI

struct ContentView: View {
    @State var project: EditorProject

    @State private var isPlaying = false
    @State private var selectedTool = "Select"
    @State private var selectedTrack = "Main Video"
    @State private var playhead: Double = 0.25
    @State private var speed: Double = 1
    @State private var errorMessage: String?

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
        .alert(
            "Project Error",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: project) { _, _ in
            saveProject()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "square.stack.3d.up.fill")
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("KINETIQ")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(2)

                Text(project.name)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Button {
                isPlaying.toggle()
            } label: {
                Label(
                    isPlaying ? "Pause" : "Preview",
                    systemImage: isPlaying ? "pause.fill" : "play.fill"
                )
                .font(.system(size: 11, weight: .semibold))
                .padding(10)
                .background(accent.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)

            Button {
                saveProject()
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 34, height: 34)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
    }

    private var compactEditor: some View {
        VStack(spacing: 10) {
            PreviewPlaceholder(isPlaying: isPlaying)
                .padding(.horizontal, 12)
                .padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tools, id: \.0) { tool in
                        Button {
                            selectedTool = tool.0
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: tool.1)

                                Text(tool.0)
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(
                                selectedTool == tool.0
                                    ? accent
                                    : .white.opacity(0.65)
                            )
                            .frame(width: 60, height: 54)
                            .background(
                                selectedTool == tool.0
                                    ? accent.opacity(0.12)
                                    : panel
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }

            if selectedTool == "Media" {
                MediaLibraryView(project: $project)
            } else {
                inspector
            }

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

                Text(
                    project.clips.isEmpty
                        ? "No clips on the timeline"
                        : "\(project.clips.count) timeline clips"
                )
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.45))

                if selectedTool == "Media" {
                    ScrollView {
                        MediaLibraryView(project: $project)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().overlay(.white.opacity(0.08))

            if selectedTool != "Media" {
                inspector
                    .frame(width: 220)
            }
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(
                selectedTool == "Select"
                    ? "Inspector"
                    : selectedTool.uppercased()
            )
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
                Text(
                    "\(speed.formatted(.number.precision(.fractionLength(2))))×"
                )
                .font(.system(size: 20, weight: .semibold))

                Slider(value: $speed, in: 0.25...3, step: 0.25)
                    .tint(accent)
            } else {
                Text("Project")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))

                Text(project.name)
                    .font(.system(size: 12))

                Button {
                    saveProject()
                } label: {
                    Label("Save project", systemImage: "checkmark")
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
        VStack(spacing: 8) {
            HStack {
                Text("TIMELINE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)

                Spacer()

                Text("\(project.clips.count) clips")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))

                Button {
                    saveProject()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
            }

            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 3) {
                        ForEach(
                            EditorClip.ClipTrack.allCases,
                            id: \.self
                        ) { track in
                            HStack(spacing: 8) {
                                Text(track.rawValue.capitalized)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.65))
                                    .frame(width: 76, alignment: .leading)

                                HStack(spacing: 4) {
                                    ForEach(
                                        project.clips.filter {
                                            $0.track == track
                                        }
                                    ) { clip in
                                        Button {
                                            selectedTrack = clip.displayName
                                        } label: {
                                            TimelineClipView(
                                                title: clip.displayName,
                                                color: color(for: track),
                                                isSelected:
                                                    selectedTrack == clip.displayName
                                            )
                                            .frame(
                                                width: max(
                                                    70,
                                                    clip.duration * 18
                                                ),
                                                height: 34
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    if project.clips.filter({
                                        $0.track == track
                                    }).isEmpty {
                                        Rectangle()
                                            .fill(.white.opacity(0.04))
                                            .frame(height: 34)
                                    }
                                }
                            }
                            .frame(height: 38)
                        }
                    }

                    Rectangle()
                        .fill(accent)
                        .frame(width: 2)
                        .offset(
                            x: 86 + (geometry.size.width - 90) * playhead
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 155)
            .clipped()
        }
        .padding(12)
        .frame(height: 205)
        .background(panel)
    }

    private func color(for track: EditorClip.ClipTrack) -> Color {
        switch track {
        case .video: return .blue
        case .overlay: return .purple
        case .audio: return .green
        case .title: return .orange
        }
    }

    private func saveProject() {
        do {
            project.modifiedAt = Date()
            try ProjectStorage.save(project)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
