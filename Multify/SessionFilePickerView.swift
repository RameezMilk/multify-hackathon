import SwiftUI
import AppKit

struct SessionFilePickerView: View {

    let files: [URL]

    var body: some View {
        List(files, id: \.self) { fileURL in
            HStack(spacing: 8) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: fileURL.path))
                    .resizable()
                    .frame(width: 16, height: 16)

                Text(fileURL.lastPathComponent)
                    .font(.system(size: 13))
                    .lineLimit(1)
            }
            .padding(.vertical, 2)
            .onDrag {
                NSItemProvider(contentsOf: fileURL)!
            }
        }
        .frame(width: 320, height: min(CGFloat(files.count) * 28, 240))
    }
}
