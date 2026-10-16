
import Foundation

struct EditorClip: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var mediaFilename: String
    var displayName: String
    var track: ClipTrack
    var startTime: Double
    var duration: Double
    var speed: Double = 1.0

    enum ClipTrack: String, Codable, CaseIterable {
        case video
        case overlay
        case audio
        case title
    }
}

struct EditorProject: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    var clips: [EditorClip] = []

    mutating func addClip(_ clip: EditorClip) {
        clips.append(clip)
        modifiedAt = Date()
    }

    mutating func removeClip(id: UUID) {
        clips.removeAll { $0.id == id }
        modifiedAt = Date()
    }
}

enum ProjectStorage {
    private static var projectsDirectory: URL {
        get throws {
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            return appSupport.appendingPathComponent(
                "KinetiqProjects",
                isDirectory: true
            )
        }
    }

    static func save(_ project: EditorProject) throws {
        let directory = try projectsDirectory

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let url = directory.appendingPathComponent(
            "\(project.id.uuidString).json"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(project)
        try data.write(to: url, options: .atomic)
    }

    static func load(id: UUID) throws -> EditorProject {
        let url = try projectsDirectory
            .appendingPathComponent("\(id.uuidString).json")

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(EditorProject.self, from: data)
    }

    static func list() throws -> [EditorProject] {
        let directory = try projectsDirectory

        guard FileManager.default.fileExists(
            atPath: directory.path
        ) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension == "json" }
        .compactMap { url in
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }

            return try? decoder.decode(EditorProject.self, from: data)
        }
        .sorted { $0.modifiedAt > $1.modifiedAt }
    }

    static func delete(id: UUID) throws {
        let url = try projectsDirectory
            .appendingPathComponent("\(id.uuidString).json")

        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
