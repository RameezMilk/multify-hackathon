import Foundation
import Combine
import AppKit

enum SessionState {
    case idle
    case recording
    case processing
    case ready
}

struct CaptureStep {
    let id: UUID
    let timestamp: Date
    let image: NSImage
    let sourceURL: URL
}

final class SessionManager: ObservableObject {
    
    private let audioRecorder = AudioRecorder()
    private let transcriber = SpeechTranscriber()

    @Published var transcriptSegments: [TranscriptSegment] = []
    @Published var captures: [CaptureStep] = []
    @Published var state: SessionState = .idle

    private var screenshotWatcher: ScreenshotWatcher?
    private var sessionStartTime: Date?
    private var sessionTempDirectory: URL?
    private var processedScreenshotURLs: Set<URL> = []
    private var screenshotFolderURL: URL?

    // MARK: - Screenshot Handling

    private func handleScreenshot(at url: URL) {
        guard !processedScreenshotURLs.contains(url) else { return }
        processedScreenshotURLs.insert(url)
        
        guard let sessionStart = sessionStartTime else { return }

        guard
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
            let creationDate = attrs[.creationDate] as? Date,
            creationDate >= sessionStart
        else { return }

        guard let image = NSImage(contentsOf: url) else { return }
        guard let tempDir = sessionTempDirectory else { return }

        let destinationURL = tempDir.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.copyItem(at: url, to: destinationURL)

        DispatchQueue.main.async {
            let capture = CaptureStep(
                id: UUID(),
                timestamp: creationDate,
                image: image,
                sourceURL: destinationURL
            )
            self.captures.append(capture)
            print("Screenshot captured:", destinationURL.lastPathComponent)
        }
    }

    // MARK: - Session Lifecycle

    func startSession() {
        guard state == .idle else { return }

        transcriber.requestSpeechAuthorizationIfNeeded { [weak self] authorized in
            guard let self = self, authorized else {
                print("Speech recognition not authorized")
                return
            }

            ScreenshotFolderAccess.requestAccessIfNeeded { [weak self] folderURL in
                guard let self = self, let folderURL = folderURL else {
                    print("Screenshot folder access denied.")
                    return
                }

                DispatchQueue.main.async {
                    self.beginSession(with: folderURL)
                }
            }
        }
    }

    private func beginSession(with screenshotFolder: URL) {
        screenshotFolderURL = screenshotFolder
        sessionStartTime = Date()
        processedScreenshotURLs.removeAll()
        captures.removeAll()
        transcriptSegments.removeAll()

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("Multify-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )
        sessionTempDirectory = tempDir

        screenshotWatcher = ScreenshotWatcher(directoryURL: screenshotFolder) { [weak self] url in
            self?.handleScreenshot(at: url)
        }

        screenshotWatcher?.start()
        audioRecorder.startRecording()
        state = .recording
    }

    func stopSession() {
        guard state == .recording else { return }

        screenshotWatcher?.stop()
        screenshotWatcher = nil

        audioRecorder.stopRecording()
        state = .processing

        if let audioURL = audioRecorder.audioFileURL {
            transcriber.transcribeAudio(url: audioURL) { segments in
                DispatchQueue.main.async {
                    self.transcriptSegments = segments
                    self.state = .ready
                    print("Transcription complete")
                }
            }
        }

        screenshotFolderURL?.stopAccessingSecurityScopedResource()
        screenshotFolderURL = nil
    }

    func resetSession() {
        state = .idle
        captures.removeAll()
        transcriptSegments.removeAll()
        print("Session reset")
    }

    // MARK: - Prompt Construction (Option A: Cumulative, Lossless)

    func buildPromptSteps() -> [PromptStep] {
        guard let sessionStart = sessionStartTime else { return [] }

        let sortedCaptures = captures.sorted { $0.timestamp < $1.timestamp }
        let sortedSegments = transcriptSegments.sorted { $0.startTime < $1.startTime }

        var steps: [PromptStep] = []
        var segmentIndex = 0

        for (index, capture) in sortedCaptures.enumerated() {
            let captureTime = capture.timestamp.timeIntervalSince(sessionStart)

            var collectedText: [String] = []

            while segmentIndex < sortedSegments.count {
                let segment = sortedSegments[segmentIndex]
                if segment.startTime <= captureTime {
                    collectedText.append(segment.text)
                    segmentIndex += 1
                } else {
                    break
                }
            }

            let step = PromptStep(
                stepIndex: index + 1,
                screenshot: capture,
                transcriptText: collectedText.joined(separator: " ")
            )

            steps.append(step)
        }

        return steps
    }

    // MARK: - Clipboard Export (Text-Only)

    func exportToClipboard() {
        guard state == .ready else {
            print("Cannot export: prompt not ready")
            return
        }

        let steps = buildPromptSteps()
        guard !steps.isEmpty else {
            print("No prompt steps to export")
            return
        }

        ClipboardExporter.copyPrompt(steps: steps)
        print("Prompt copied to clipboard (text only)")
    }
    
    // MARK: - Session Screenshot Files (UI helper)

    func sessionScreenshotFiles() -> [URL] {
        captures
            .sorted { $0.timestamp < $1.timestamp }
            .map { $0.sourceURL }
    }

}
