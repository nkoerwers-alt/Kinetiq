
import SwiftUI
import UniformTypeIdentifiers

struct MediaLibraryView: View {
    @Binding var project: EditorProject

    @State private var mediaFiles: [URL] = []
    @State private var showImporter = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MEDIA LIBRARY")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1)

                Spacer()

                Button {
                    showImporter = true
                } label: {
                    Label("Import", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }

            if mediaFiles.isEmpty {
                ContentUnavailableView(
                    "No Media",
                    systemImage: "film",
                    description: Text("Import files to add clips to your project.")
                )
            } else {
                ForEach(mediaFiles, id: \.absoluteString) { url in
                    HStack(spacing: 10) {
                        Image(systemName: "film")
                            .foregroundStyle(.blue)

                        Text(url.lastPathComponent)
                            .font(.system(size: 12))
                            .lineLimit(1)

                        Spacer()

                        Button {
                            addClip(url)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
        }
        .padding(12)
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.movie, .video, .audio, .image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                importFiles(urls)
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .alert(
            "Media Error",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            refreshMedia()
        }
    }

    private func refreshMedia() {
        do {
            mediaFiles = try MediaStorage.savedFiles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importFiles(_ urls: [URL]) {
        for url in urls {
            do {
                let savedURL = try MediaStorage.importFile(from: url)

                if !mediaFiles.contains(savedURL) {
                    mediaFiles.append(savedURL)
                }
            } catch {
                errorMessage = "Could not import \(url.lastPathComponent): \(error.localizedDescription)"
            }
        }
    }

    private func addClip(_ url: URL) {
        let name = url.deletingPathExtension().lastPathComponent

        let clip = EditorClip(
            mediaFilename: url.lastPathComponent,
            displayName: name,
            track: .video,
            startTime: 0,
            duration: 5
        )

        project.addClip(clip)

        do {
            try ProjectStorage.save(project)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
