import Foundation

/// Lightweight filter to remove common filler words from transcribed text
/// This runs before LLM refinement for quick, local cleanup
public struct FillerWordFilter {

    // MARK: - Filler Word Definitions

    /// Common Chinese filler words and phrases
    private static let chineseFillers: [String] = [
        // Single character fillers
        "额", "嗯", "啊", "呃", "哦", "噢", "唉", "哎",
        // Two character fillers
        "那个", "这个", "就是", "然后", "所以", "因为", "但是", "可是",
        "其实", "反正", "总之", "大概", "应该", "可能", "好像", "感觉",
        // Common speech fillers
        "就是说", "怎么说", "你知道", "我觉得", "我感觉", "我想说",
        "说实话", "老实说", "坦白说", "不是说", "我是说",
        // Hesitation patterns
        "嗯嗯", "额额", "啊啊", "呃呃", "嗯额", "额嗯"
    ]

    /// Common English filler words and phrases
    private static let englishFillers: [String] = [
        // Single word fillers
        "um", "uh", "er", "ah", "oh", "hmm", "hm", "mm",
        "like", "so", "well", "right", "okay", "ok",
        // Phrases
        "you know", "i mean", "you see", "basically", "actually",
        "literally", "honestly", "seriously", "obviously",
        "kind of", "sort of", "kinda", "sorta",
        "i guess", "i think", "i suppose", "i believe",
        "to be honest", "to be fair", "in fact", "as a matter of fact"
    ]

    // MARK: - Settings

    /// Whether filler word filtering is enabled
    public static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "FillerWordFilterEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "FillerWordFilterEnabled") }
    }

    /// Aggressiveness level: 0 = minimal, 1 = moderate, 2 = aggressive
    public static var aggressiveness: Int {
        get { UserDefaults.standard.integer(forKey: "FillerWordFilterAggressiveness") }
        set { UserDefaults.standard.set(newValue, forKey: "FillerWordFilterAggressiveness") }
    }

    // MARK: - Public API

    /// Filters filler words from the given text
    /// - Parameter text: The transcribed text to filter
    /// - Returns: Text with filler words removed
    public static func filter(_ text: String) -> String {
        guard isEnabled, !text.isEmpty else { return text }

        var result = text

        // Apply Chinese filler removal
        result = removeChineseFillers(from: result)

        // Apply English filler removal
        result = removeEnglishFillers(from: result)

        // Clean up extra whitespace and punctuation
        result = cleanupWhitespace(result)

        return result
    }

    // MARK: - Private Methods

    /// Remove Chinese filler words
    private static func removeChineseFillers(from text: String) -> String {
        var result = text

        // Get fillers based on aggressiveness level
        let fillersToRemove = getChineseFillersForLevel(aggressiveness)

        for filler in fillersToRemove {
            // Remove filler when it appears:
            // 1. At the start of text followed by optional punctuation
            // 2. After punctuation (。，、！？)
            // 3. Standalone with surrounding whitespace

            // Pattern: filler followed by optional comma/space
            let patterns = [
                "^\(filler)[，、,\\s]*",           // At start
                "([。！？，、])\\s*\(filler)[，、,\\s]*", // After punctuation
                "\\s+\(filler)[，、,\\s]*",        // After whitespace
            ]

            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                    let range = NSRange(result.startIndex..., in: result)
                    // For patterns with capture groups, preserve the punctuation
                    let replacement = pattern.contains("(") ? "$1" : ""
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
                }
            }
        }

        return result
    }

    /// Remove English filler words
    private static func removeEnglishFillers(from text: String) -> String {
        var result = text

        // Get fillers based on aggressiveness level
        let fillersToRemove = getEnglishFillersForLevel(aggressiveness)

        for filler in fillersToRemove {
            // Word boundary aware removal
            let patterns = [
                "^\\s*\(NSRegularExpression.escapedPattern(for: filler))[,\\s]*",  // At start
                "([.!?])\\s*\(NSRegularExpression.escapedPattern(for: filler))[,\\s]*", // After sentence end
                ",\\s*\(NSRegularExpression.escapedPattern(for: filler))[,\\s]*",  // After comma
                "\\s+\(NSRegularExpression.escapedPattern(for: filler))[,\\s]*(?=\\s|$|[.!?])", // Mid-sentence
            ]

            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                    let range = NSRange(result.startIndex..., in: result)
                    let replacement = pattern.contains("(") ? "$1 " : " "
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
                }
            }
        }

        return result
    }

    /// Get Chinese fillers based on aggressiveness level
    private static func getChineseFillersForLevel(_ level: Int) -> [String] {
        switch level {
        case 0: // Minimal - only obvious fillers
            return ["额", "嗯", "啊", "呃", "嗯嗯", "额额", "啊啊", "呃呃"]
        case 1: // Moderate - common fillers
            return Array(chineseFillers.prefix(16))
        default: // Aggressive - all fillers
            return chineseFillers
        }
    }

    /// Get English fillers based on aggressiveness level
    private static func getEnglishFillersForLevel(_ level: Int) -> [String] {
        switch level {
        case 0: // Minimal - only obvious fillers
            return ["um", "uh", "er", "ah", "hmm", "hm", "mm"]
        case 1: // Moderate - common fillers
            return Array(englishFillers.prefix(14))
        default: // Aggressive - all fillers
            return englishFillers
        }
    }

    /// Clean up extra whitespace and fix punctuation spacing
    private static func cleanupWhitespace(_ text: String) -> String {
        var result = text

        // Replace multiple spaces with single space
        if let regex = try? NSRegularExpression(pattern: "\\s{2,}", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: " ")
        }

        // Remove space before Chinese punctuation
        if let regex = try? NSRegularExpression(pattern: "\\s+([。，、！？）】」』])", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Remove space after Chinese opening punctuation
        if let regex = try? NSRegularExpression(pattern: "([（【「『])\\s+", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Fix double punctuation
        if let regex = try? NSRegularExpression(pattern: "([。！？]){2,}", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Trim leading/trailing whitespace
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }
}

// MARK: - Convenience Extension

extension String {
    /// Returns this string with filler words removed
    var withoutFillerWords: String {
        FillerWordFilter.filter(self)
    }
}
