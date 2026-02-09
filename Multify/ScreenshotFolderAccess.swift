import AppKit

struct ScreenshotFolderAccess {

    private static let bookmarkKey = "ScreenshotFolderBookmark"

    static func requestAccessIfNeeded(completion: @escaping (URL?) -> Void) {

        if let existingURL = restoreAccess() {
            completion(existingURL)
            return
        }

        let panel = NSOpenPanel()
        panel.title = "Select your Screenshots folder"
        panel.message = "Multify needs access to this folder to attach screenshots to your explanation."
        panel.prompt = "Allow"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                completion(nil)
                return
            }

            saveAccess(for: url)
            completion(url)
        }
    }

    private static func saveAccess(for url: URL) {
        do {
            let bookmark = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
        } catch {
            print("Failed to save screenshot folder bookmark:", error)
        }
    }

    static func restoreAccess() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }

        var stale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            )

            if url.startAccessingSecurityScopedResource() {
                return url
            }
        } catch {
            print("Failed to restore screenshot folder access:", error)
        }

        return nil
    }
}
