import Foundation
import AVFoundation

final class AudioRecorder: NSObject, AVAudioRecorderDelegate {

    private var recorder: AVAudioRecorder?
    private(set) var audioFileURL: URL?

    func startRecording() {
        let fileName = "multify_audio_\(Date().timeIntervalSince1970).wav"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        audioFileURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]

        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()

            let started = recorder?.record() ?? false
            print("Recorder started:", started)

            // Poll audio level
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                guard let recorder = self.recorder, recorder.isRecording else {
                    timer.invalidate()
                    return
                }

                recorder.updateMeters()
                let power = recorder.averagePower(forChannel: 0)
                print("Mic power:", power)
            }

        } catch {
            print("Audio recorder failed:", error)
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        print("Audio recording stopped")
    }
}
