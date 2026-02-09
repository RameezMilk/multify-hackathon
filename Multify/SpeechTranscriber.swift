import Foundation
import Speech

struct TranscriptSegment {
    let text: String
    let startTime: TimeInterval
    let endTime: TimeInterval
}

final class SpeechTranscriber {
    
    func requestSpeechAuthorizationIfNeeded(
        completion: @escaping (Bool) -> Void
    ) {
        let status = SFSpeechRecognizer.authorizationStatus()

        switch status {
        case .authorized:
            completion(true)

        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }

        default:
            completion(false)
        }
    }

    func transcribeAudio(
        url: URL,
        completion: @escaping ([TranscriptSegment]) -> Void
    ) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                print("Speech recognition not authorized")
                completion([])
                return
            }

            let recognizer = SFSpeechRecognizer()
            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = false

            recognizer?.recognitionTask(with: request) { result, error in
                guard let result = result, result.isFinal else { return }

                let segments = result.bestTranscription.segments.map { segment in
                    TranscriptSegment(
                        text: segment.substring,
                        startTime: segment.timestamp,
                        endTime: segment.timestamp + segment.duration
                    )
                }

                completion(segments)
            }
        }
    }
}
