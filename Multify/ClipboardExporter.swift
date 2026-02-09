import AppKit

final class ClipboardExporter {

    static func copyPrompt(steps: [PromptStep]) {
        let pasteboard = NSPasteboard.general

        // 🚨 Critical: clear everything so no images linger
        pasteboard.clearContents()

        // Build prompt text (unchanged logic)
        let text = buildPromptText(from: steps)

        // Write TEXT ONLY
        pasteboard.setString(text, forType: .string)

        print("Prompt copied to clipboard (text only)")
    }

    private static func buildPromptText(from steps: [PromptStep]) -> String {
        var output: [String] = []

        output.append("""
        You are an AI coding assistant.

        I recorded my screen and voice to describe UI changes.
        Screenshots are attached separately and referenced by filename.

        Please follow the steps in order.
        """)

        for step in steps {
            output.append("""
            
            STEP \(step.stepIndex)
            Screenshot: \(step.screenshot.sourceURL.lastPathComponent)
            Instruction:
            \(step.transcriptText)
            """)
        }

        output.append("""
        
        Notes:
        - Infer component structure from the codebase.
        - Scrape the codebase before making changes.
        """)

        return output.joined(separator: "\n")
    }
}
