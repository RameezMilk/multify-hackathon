import Foundation

struct ScreenshotLocationResolver {

    static func screenshotDirectory() -> URL {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.screencapture", "location"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let path = output, !path.isEmpty {
                return URL(fileURLWithPath: path)
            }
        } catch {}

        // Fallback
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
    }
}
