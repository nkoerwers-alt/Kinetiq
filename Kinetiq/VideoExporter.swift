
import Foundation
import AVFoundation

enum VideoExporterError: LocalizedError {
    case noVideoTrack
    case exportSessionUnavailable
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            return "The selected file has no video track."
        case .exportSessionUnavailable:
            return "Could not create an export session."
        case .exportFailed(let message):
            return "Export failed: \(message)"
        }
    }
}

enum VideoExporter {
    static func exportVideo(
        from sourceURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let asset = AVURLAsset(url: sourceURL)

        Task {
            do {
                let tracks = try await asset.loadTracks(withMediaType: .video)

                guard !tracks.isEmpty else {
                    throw VideoExporterError.noVideoTrack
                }

                guard let session = AVAssetExportSession(
                    asset: asset,
                    presetName: AVAssetExportPresetHighestQuality
                ) else {
                    throw VideoExporterError.exportSessionUnavailable
                }

                let outputURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(UUID().uuidString).mp4")

                session.outputURL = outputURL
                session.outputFileType = .mp4
                session.shouldOptimizeForNetworkUse = true

                await session.export()

                switch session.status {
                case .completed:
                    completion(.success(outputURL))

                case .failed:
                    completion(.failure(
                        session.error ?? VideoExporterError.exportFailed("Unknown error")
                    ))

                case .cancelled:
                    completion(.failure(
                        VideoExporterError.exportFailed("Export cancelled")
                    ))

                default:
                    completion(.failure(
                        VideoExporterError.exportFailed("Export did not complete")
                    ))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
