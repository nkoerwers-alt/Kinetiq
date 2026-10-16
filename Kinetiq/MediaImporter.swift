
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation

struct ImportedMedia: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let type: MediaType

    enum MediaType {
        case video
        case audio
        case image
    }
}

struct MediaImporter: View {
    @State private var showImporter = false
    @State private var importedMedia: [ImportedMedia] = []
    @State private var errorMessage: String?

    var onImport: (ImportedMedia) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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

            if importedMedia.isEmpty {
                ContentUnavailableView(
                    "No media yet",
                    systemImage: "film",
                    description: Text("Import video, audio or images from Files.")
                )
                .frame(maxWidth: .infinity)
            } else {
                ForEach(importedMedia) { media in
                    Button {
                        onImport(media)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: icon(for: media.type))
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(media.name)
                                    .lineLimit(1)

                                Text(media.type.rawValue.capitalized)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "plus.circle")
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 11))
                    .foregroundStyle(.red)
            }
        }
        .padding(14)
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.movie, .video, .audio, .image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    let hasAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if hasAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }

                    let mediaType: ImportedMedia.MediaType

                    if let type = UTType(filenameExtension: url.pathExtension) {
                        if type.conforms(to: .audio) {
                            mediaType = .audio
                        } else if type.conforms(to: .image) {
                            mediaType = .image
                        } else {
                            mediaType = .video
                        }
                    } else {
                        mediaType = .video
                    }

                    let media = ImportedMedia(
                        url: url,
                        name: url.lastPathComponent,
                        type: mediaType
                    )

                    importedMedia.append(media)
                    onImport(media)
                }

            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func icon(for type: ImportedMedia.MediaType) -> String {
        switch type {
        case .video: return "film"
        case .audio: return "waveform"
        case .image: return "photo"
        }
    }
}
