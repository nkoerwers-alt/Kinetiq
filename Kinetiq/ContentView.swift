
import SwiftUI

struct ContentView: View {
    @State var project: EditorProject

    @State private var isPlaying = false
    @State private var selectedTool = "Select"
    @State private var selectedTrack = "Main Video"
    @State private var selectedClipID: UUID?
    @State private var playhead: Double = 0.25
    @State private var speed: Double = 1
    @State private var previewURL: URL?
    @State private var errorMessage: String?
    @State private var showTrimmer = false
    @State private var showExport = false
    @State private var exportSourceURL: URL?
    @State private var exportStartTime: Double = 0
    @State private var exportDuration: Double?

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

    private var selectedClip: EditorClip? {
        project.clips.first { $0.id == selectedClipID }
    }

    private var selectedClipURL: URL? {
        guard let clip = selectedClip else { return nil }

        return try? MediaStorage.savedFiles().first {
            $0.lastPathComponent == clip.mediaFilename
        }
    }

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
        .sheet(isPresented: $showTrimmer) {
            if let url = selectedClipURL, let clip = selectedClip {
                ClipTrimmerView(url: url) { start, duration in
                    applyTrim(
                        clipID: clip.id,
                        start: start,
                        duration: duration
                    )
                    showTrimmer = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "film")
                        .font(.system(size: 30))

                    Text("Select a video clip first.")

                    Button("Close") {
                        showTrimmer = false
                    }
                }
                .padding(30)
                .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showExport) {
            if let exportSourceURL {
                ExportView(
                    sourceURL: exportSourceURL,
                    startTime: exportStartTime,
                    duration: exportDuration
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "film")
                        .font(.system(size: 30))

                    Text("Import or select a video before exporting.")

                    Button("Close") {
                        showExport = false
                    }
                }
                .padding(30)
                .presentationDetents([.medium])
            }
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

            Button(action: prepareExport) {
                Image(systemName: "square.and.arrow.up")
                    .frame(width: 34, height: 34)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Export video")

            Button(action: saveProject) {
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 34, height: 34)
                    .background(panel)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save project")
        }
        .padding(12)
    }

    private var videoPreview: some View {
        Group {
            if let previewURL,
               ["mp4", "mov", "m4v"].contains(
                    previewURL.pathExtension.lowercased()
               ) {
                VideoPreview(url: previewURL)
            } else {
                PreviewPlaceholder(isPlaying: isPlaying)
            }
        }
    }

    private var compactEditor: some View {
        VStack(spacing: 10) {
            videoPreview
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
                ScrollView {
                    MediaLibraryView(
                        project: $project,
                        previewURL: $previewURL
                    )
                }
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
                videoPreview
                    .frame(maxWidth: 760)

                Text("\(project.clips.count) timeline clips")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.45))

                if selectedTool == "Media" {
                    ScrollView {
                        MediaLibraryView(
                            project: $project,
                            previewURL: $previewURL
                        )
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().overlay(.white.opacity(0.08))

            if selectedTool != "Media" {
                inspector.frame(width: 220)
            }
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(selectedTool == "Select" ? "Inspector" : selectedTool.uppercased())
                .font(.system(size: 13, weight: .bold))
                .tracking(0.7)

            Divider().overlay(.white.opacity(0.08))

            Text("SELECTED CLIP")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.4))

            Text(selectedClip?.displayName ?? selectedTrack)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(2)

            if let clip = selectedClip {
                Text("Start: \(timeString(clip.startTime))")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.65))

                Text("Duration: \(timeString(clip.duration))")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.65))
            }

            if selectedTool == "Cut" {
                Button {
                    guard selectedClip != nil else {
                        errorMessage = "Select a timeline clip first."
                        return
                    }

                    showTrimmer = true
                } label: {
                    Label("Trim Clip", systemImage: "scissors")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(accent.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            } else if selectedTool == "Speed" {
                Text("\(speed.formatted(.number.precision(.fractionLength(2))))×")
                    .font(.system(size: 20, weight: .semibold))

                Slider(value: $speed, in: 0.25...3, step: 0.25)
                    .tint(accent)
            } else {
                Text("Project")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))

                Text(project.name)
                    .font(.system(size: 12))

                Button(action: saveProject) {
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

                Button(action: saveProject) {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
            }

            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 3) {
                        ForEach(EditorClip.ClipTrack.allCases, id: \.self) { track in
                            HStack(spacing: 8) {
                                Text(track.rawValue.capitalized)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.65))
                                    .frame(width: 76, alignment: .leading)

                                HStack(spacing: 4) {
                                    ForEach(
                                        project.clips.filter { $0.track == track }
                                    ) { clip in
                                        Button {
                                            selectedClipID = clip.id
                                            selectedTrack = clip.displayName

                                            if let url = try? MediaStorage.savedFiles().first(
                                                where: {
                                                    $0.lastPathComponent == clip.mediaFilename
                                                }
                                            ) {
                                                previewURL = url
                                            }
                                        } label: {
                                            TimelineClipView(
                                                title: clip.displayName,
                                                color: color(for: track),
                                                isSelected: selectedClipID == clip.id
                                            )
                                            .frame(
                                                width: max(70, clip.duration * 18),
                                                height: 34
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    if project.clips.filter({ $0.track == track }).isEmpty {
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

    private func prepareExport() {
        if let clip = selectedClip, let url = selectedClipURL {
            exportSourceURL = url
            exportStartTime = clip.startTime
            exportDuration = clip.duration
            showExport = true
        } else if let previewURL,
                  ["mp4", "mov", "m4v"].contains(
                    previewURL.pathExtension.lowercased()
                  ) {
            exportSourceURL = previewURL
            exportStartTime = 0
            exportDuration = nil
            showExport = true
        } else {
            errorMessage = "Import or select a video before exporting."
        }
    }

    private func color(for track: EditorClip.ClipTrack) -> Color {
        switch track {
        case .video: return .blue
        case .overlay: return .purple
        case .audio: return .green
        case .title: return .orange
        }
    }

    private func applyTrim(
        clipID: UUID,
        start: Double,
        duration: Double
    ) {
        guard let index = project.clips.firstIndex(where: { $0.id == clipID }) else {
            return
        }

        project.clips[index].startTime = start
        project.clips[index].duration = duration
        project.modifiedAt = Date()

        do {
            try ProjectStorage.save(project)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let totalSeconds = max(0, Int(seconds))
        return String(
            format: "%02d:%02d",
            totalSeconds / 60,
            totalSeconds % 60
        )
    }

    private func saveProject() {
        project.modifiedAt = Date()

        do {
            try ProjectStorage.save(project)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
