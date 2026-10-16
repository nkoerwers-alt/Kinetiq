
import Foundation

enum SplitClipError: LocalizedError {
    case clipNotFound
    case invalidSplitTime
    case invalidDuration

    var errorDescription: String? {
        switch self {
        case .clipNotFound:
            return "The selected clip could not be found."
        case .invalidSplitTime:
            return "The split point must be inside the clip."
        case .invalidDuration:
            return "The clip duration is invalid."
        }
    }
}

enum SplitClipUtility {
    static func split(
        project: inout EditorProject,
        clipID: UUID,
        at splitTime: Double
    ) throws {
        guard let index = project.clips.firstIndex(where: {
            $0.id == clipID
        }) else {
            throw SplitClipError.clipNotFound
        }

        let original = project.clips[index]

        guard original.duration > 0 else {
            throw SplitClipError.invalidDuration
        }

        guard splitTime > 0, splitTime < original.duration else {
            throw SplitClipError.invalidSplitTime
        }

        var firstClip = original
        firstClip.duration = splitTime

        var secondClip = original
        secondClip.id = UUID()
        secondClip.startTime = original.startTime + splitTime
        secondClip.duration = original.duration - splitTime

        project.clips[index] = firstClip
        project.clips.insert(secondClip, at: index + 1)
        project.modifiedAt = Date()
    }
}
