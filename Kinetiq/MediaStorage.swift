
import Foundation
import UniformTypeIdentifiers

enum MediaStorage {
    static func importFile(from sourceURL: URL) throws -> URL {
        let hasAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileManager = FileManager.default

        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let mediaFolder = appSupport.appendingPathComponent(
            "KinetiqMedia",
            isDirectory: true
        )

        try fileManager.createDirectory(
            at: mediaFolder,
            withIntermediateDirectories: true
        )

        let fileExtension = sourceURL.pathExtension
        let destinationName = "\(UUID().uuidString).\(fileExtension)"
        let destinationURL = mediaFolder.appendingPathComponent(destinationName)

        try fileManager.copyItem(
            at: sourceURL,
            to: destinationURL
        )

        return destinationURL
    }

    static func savedFiles() throws -> [URL] {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        let mediaFolder = appSupport.appendingPathComponent(
            "KinetiqMedia",
            isDirectory: true
        )

        guard FileManager.default.fileExists(atPath: mediaFolder.path) else {
            return []
        }

        return try FileManager.default.contentsOfDirectory(
            at: mediaFolder,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )
    }

    static func deleteFile(at url: URL) throws {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        let mediaFolder = appSupport
            .appendingPathComponent("KinetiqMedia", isDirectory: true)
            .standardizedFileURL

        let target = url.standardizedFileURL

        guard target.deletingLastPathComponent() == mediaFolder else {
            throw CocoaError(.fileWriteNoPermission)
        }

        try FileManager.default.removeItem(at: target)
    }
}
