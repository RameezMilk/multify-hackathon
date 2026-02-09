import SwiftUI

struct OverlayView: View {

    @EnvironmentObject var sessionManager: SessionManager
    @State private var showFiles = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.05, green: 0.45, blue: 0.32)) // metallic midnight green
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                )

            HStack(spacing: 22) {

                toolbarButton("play.fill", enabled: sessionManager.state == .idle) {
                    sessionManager.startSession()
                }

                toolbarButton("stop.fill", enabled: sessionManager.state == .recording) {
                    sessionManager.stopSession()
                }

                toolbarButton("doc.on.doc", enabled: sessionManager.state == .ready) {
                    sessionManager.exportToClipboard()
                }

                toolbarButton("folder", enabled: sessionManager.state == .ready) {
                    showFiles.toggle()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(height: 56)
        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
        .popover(isPresented: $showFiles) {
            SessionFilePickerView(files: sessionManager.sessionScreenshotFiles())
        }
    }

    private func toolbarButton(
        _ systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(enabled ? .white : .white.opacity(0.4))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
