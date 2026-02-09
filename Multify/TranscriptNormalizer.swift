import Foundation

enum TranscriptNormalizer {

    // MARK: - Public API

    static func normalize(_ text: String) -> String {
        var result = text.lowercased()

        result = removeFillerWords(from: result)
        result = normalizeNumbers(in: result)
        result = collapseRepeatedWords(in: result)
        result = normalizeWhitespace(in: result)
        result = sentenceCase(result)

        return result
    }

    // MARK: - Rules

    /// Removes common spoken filler words
    private static func removeFillerWords(from text: String) -> String {
        let fillers = [
            "um", "uh", "like", "you know", "i mean", "kind of", "sort of",
            "just", "maybe", "basically", "actually"
        ]

        var output = text
        for filler in fillers {
            output = output.replacingOccurrences(
                of: "\\b\(filler)\\b",
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }

        return output
    }

    /// Fixes numeric tokenization issues from speech recognition
    /// Example: ". 5" → "0.5", "1 . 5" → "1.5"
    private static func normalizeNumbers(in text: String) -> String {
        var output = text

        // ". 5" → "0.5"
        output = output.replacingOccurrences(
            of: "\\.\\s+(\\d)",
            with: "0.$1",
            options: .regularExpression
        )

        // "1 . 5" → "1.5"
        output = output.replacingOccurrences(
            of: "(\\d)\\s+\\.\\s+(\\d)",
            with: "$1.$2",
            options: .regularExpression
        )

        return output
    }

    /// Collapses repeated adjacent words
    /// Example: "the the margin" → "the margin"
    private static func collapseRepeatedWords(in text: String) -> String {
        return text.replacingOccurrences(
            of: "\\b(\\w+)\\s+\\1\\b",
            with: "$1",
            options: .regularExpression
        )
    }

    /// Normalizes whitespace
    private static func normalizeWhitespace(in text: String) -> String {
        text
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Converts text into sentence-case, instruction-style output
    private static func sentenceCase(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }
}
