import Foundation

final class ScreenshotWatcher {

    private let directoryURL: URL
    private let handler: (URL) -> Void

    private var directoryFileDescriptor: Int32 = -1
    private var source: DispatchSourceFileSystemObject?

    init(directoryURL: URL, handler: @escaping (URL) -> Void) {
        self.directoryURL = directoryURL
        self.handler = handler
    }

    func start() {
        stop()

        directoryFileDescriptor = open(directoryURL.path, O_EVTONLY)
        guard directoryFileDescriptor != -1 else {
            print("ScreenshotWatcher: failed to open directory:", directoryURL.path)
            return
        }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: directoryFileDescriptor,
            eventMask: [.write, .rename],
            queue: DispatchQueue.global(qos: .utility)
        )

        source?.setEventHandler { [weak self] in
            self?.scanDirectory()
        }

        source?.setCancelHandler { [weak self] in
            if let fd = self?.directoryFileDescriptor, fd != -1 {
                close(fd)
            }
        }

        source?.resume()
        print("ScreenshotWatcher: started watching", directoryURL.path)
    }

    func stop() {
        source?.cancel()
        source = nil

        if directoryFileDescriptor != -1 {
            close(directoryFileDescriptor)
            directoryFileDescriptor = -1
        }
    }

    private func scanDirectory() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        for file in files {
            handler(file)
        }
    }
}
