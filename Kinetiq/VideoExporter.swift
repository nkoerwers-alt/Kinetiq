
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
        startTime: Double = 0,
        duration: Double? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        Task {
            do {
                let asset = AVURLAsset(url: sourceURL)
                let tracks = try await asset.loadTracks(withMediaType: .video)

                guard !tracks.isEmpty else {
                    throw VideoExporterError.noVideoTrack
                }

                let assetDuration = try await asset.load(.duration)
                let totalSeconds = CMTimeGetSeconds(assetDuration)

                guard totalSeconds.isFinite, totalSeconds > 0 else {
                    throw VideoExporterError.exportFailed(
                        "The video duration is invalid."
                    )
                }

                let safeStart = max(0, min(startTime, totalSeconds))
                let requestedDuration = duration ?? (totalSeconds - safeStart)
                let safeDuration = min(
                    max(0, requestedDuration),
                    totalSeconds - safeStart
                )

                guard safeDuration > 0 else {
                    throw VideoExporterError.exportFailed(
                        "The selected trim range is empty."
                    )
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
                session.timeRange = CMTimeRange(
                    start: CMTime(seconds: safeStart, preferredTimescale: 600),
                    duration: CMTime(seconds: safeDuration, preferredTimescale: 600)
                )

                await session.export()

                switch session.status {
                case .completed:
                    await MainActor.run {
                        completion(.success(outputURL))
                    }
                case .failed:
                    let error = session.error
                        ?? VideoExporterError.exportFailed("Unknown error")

                    await MainActor.run {
                        completion(.failure(error))
                    }
                case .cancelled:
                    await MainActor.run {
                        completion(.failure(
                            VideoExporterError.exportFailed("Export cancelled.")
                        ))
                    }
                default:
                    await MainActor.run {
                        completion(.failure(
                            VideoExporterError.exportFailed(
                                "Export did not complete."
                            )
                        ))
                    }
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
