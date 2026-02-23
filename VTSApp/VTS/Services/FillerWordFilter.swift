import Foundation

/// Lightweight filter to remove common filler words and speech artifacts from transcribed text
/// This runs before LLM refinement for quick, local cleanup
public struct FillerWordFilter {

    // MARK: - Filler Word Definitions

    /// Common Chinese filler words and phrases
    private static let chineseFillers: [String] = [
        "额", "嗯", "啊", "呃", "哦", "噢", "唉", "哎",
        "那个", "这个", "就是", "然后", "所以", "因为", "但是", "可是",
        "其实", "反正", "总之", "大概", "应该", "可能", "好像", "感觉",
        "就是说", "怎么说", "你知道", "我觉得", "我感觉", "我想说",
        "说实话", "老实说", "坦白说", "不是说", "我是说"
    ]

    /// Common English filler words and phrases
    private static let englishFillers: [String] = [
        "um", "uh", "er", "ah", "oh", "hmm", "hm", "mm",
        "like", "so", "well", "right", "okay", "ok",
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

        // 1. Remove repeated words (e.g., "the the" -> "the", "那个那个" -> "那个")
        result = removeRepeatedWords(result)

        // 2. Apply Chinese filler removal
        result = removeChineseFillers(from: result)

        // 3. Apply English filler removal
        result = removeEnglishFillers(from: result)

        // 4. Clean up extra whitespace and punctuation
        result = cleanupWhitespace(result)

        return result
    }

    // MARK: - Private Methods

    /// Remove repeated words that often occur in speech (e.g., "I I think" -> "I think")
    private static func removeRepeatedWords(_ text: String) -> String {
        var result = text
        
        // English repeated words: \b(\w+)\b(\s+\1\b)+
        if let enRegex = try? NSRegularExpression(pattern: "\\b(\\w+)\\b(\\s+\\1\\b)+", options: [.caseInsensitive]) {
            let range = NSRange(result.startIndex..., in: result)
            result = enRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }
        
        // Chinese repeated words (single character): ([\u4e00-\u9fa5])\1+
        if let zhSingleRegex = try? NSRegularExpression(pattern: "([\\u4e00-\\u9fa5])\\1+", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = zhSingleRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Chinese repeated words (multi-character): ([\u4e00-\u9fa5]{2,})\1+
        if let zhMultiRegex = try? NSRegularExpression(pattern: "([\\u4e00-\\u9fa5]{2,})\\1+", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = zhMultiRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }
        
        return result
    }

    /// Remove Chinese filler words
    private static func removeChineseFillers(from text: String) -> String {
        var result = text
        let fillersToRemove = getChineseFillersForLevel(aggressiveness)
        
        // Optimize: use a single regex for all fillers for performance
        let fillerPattern = fillersToRemove.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        
        // Pattern: filler followed by optional punctuation or at start
        let patterns = [
            "^(\(fillerPattern))[，、,\\s]*",           // At start
            "([。！？，、])\\s*(\(fillerPattern))[，、,\\s]*", // After punctuation
            "\\s+(\(fillerPattern))[，、,\\s]*",        // After whitespace
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(result.startIndex..., in: result)
                let replacement = pattern.contains("(") ? "$1" : ""
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        return result
    }

    /// Remove English filler words
    private static func removeEnglishFillers(from text: String) -> String {
        var result = text
        let fillersToRemove = getEnglishFillersForLevel(aggressiveness)
        
        let fillerPattern = fillersToRemove.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")

        let patterns = [
            "^\\s*(\(fillerPattern))[,\\s]*",  // At start
            "([.!?])\\s*(\(fillerPattern))[,\\s]*", // After sentence end
            ",\\s*(\(fillerPattern))[,\\s]*",  // After comma
            "\\s+(\(fillerPattern))[,\\s]*(?=\\s|$|[.!?])", // Mid-sentence
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(result.startIndex..., in: result)
                let replacement = pattern.contains("(") ? "$1 " : " "
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        return result
    }

    private static func getChineseFillersForLevel(_ level: Int) -> [String] {
        switch level {
        case 0: return ["额", "嗯", "啊", "呃"]
        case 1: return Array(chineseFillers.prefix(15))
        default: return chineseFillers
        }
    }

    private static func getEnglishFillersForLevel(_ level: Int) -> [String] {
        switch level {
        case 0: return ["um", "uh", "er", "ah", "hmm"]
        case 1: return Array(englishFillers.prefix(12))
        default: return englishFillers
        }
    }

    private static func cleanupWhitespace(_ text: String) -> String {
        var result = text

        if let regex = try? NSRegularExpression(pattern: "\\s{2,}", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: " ")
        }

        if let regex = try? NSRegularExpression(pattern: "\\s+([。，、！？）】」』])", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
}
