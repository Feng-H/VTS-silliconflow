import Foundation

/// Processes voice commands embedded in transcribed text
/// Converts spoken punctuation and commands into actual symbols/actions
public struct VoiceCommandProcessor {

    // MARK: - Settings

    /// Whether voice command processing is enabled
    public static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "VoiceCommandProcessorEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "VoiceCommandProcessorEnabled") }
    }

    // MARK: - Command Definitions

    /// Punctuation commands mapped to their symbols
    private static let punctuationCommands: [(patterns: [String], replacement: String)] = [
        // Period/Full stop
        (["句号", "句點", "period", "full stop", "dot"], "。"),
        // Comma
        (["逗号", "逗號", "comma"], "，"),
        // Question mark
        (["问号", "問號", "question mark"], "？"),
        // Exclamation mark
        (["叹号", "感叹号", "感嘆號", "exclamation mark", "exclamation point"], "！"),
        // Colon
        (["冒号", "冒號", "colon"], "："),
        // Semicolon
        (["分号", "分號", "semicolon"], "；"),
        // Quotation marks
        (["引号", "引號", "开始引号", "quote", "open quote"], "「"),
        (["结束引号", "關閉引號", "close quote", "end quote", "unquote"], "」"),
        // Parentheses
        (["左括号", "左括號", "open parenthesis", "open paren", "left paren"], "（"),
        (["右括号", "右括號", "close parenthesis", "close paren", "right paren"], "）"),
        // Dash/Hyphen
        (["破折号", "破折號", "dash", "hyphen"], "——"),
        // Ellipsis
        (["省略号", "省略號", "ellipsis", "dot dot dot"], "……"),
        // Space (for languages that don't typically use spaces)
        (["空格", "space"], " "),
    ]

    /// Format commands that affect text structure
    private static let formatCommands: [(patterns: [String], action: FormatAction)] = [
        // New line
        (["换行", "換行", "new line", "newline", "next line"], .newLine),
        // New paragraph
        (["新段落", "新段", "new paragraph", "next paragraph"], .newParagraph),
        // Tab
        (["制表符", "tab", "indent"], .tab),
    ]

    /// Enum for format actions
    private enum FormatAction {
        case newLine
        case newParagraph
        case tab

        var replacement: String {
            switch self {
            case .newLine:
                return "\n"
            case .newParagraph:
                return "\n\n"
            case .tab:
                return "\t"
            }
        }
    }

    // MARK: - Public API

    /// Process voice commands in the given text
    /// - Parameter text: The transcribed text potentially containing voice commands
    /// - Returns: Text with voice commands converted to actual symbols
    public static func process(_ text: String) -> String {
        guard isEnabled, !text.isEmpty else { return text }

        var result = text

        // Process punctuation commands
        result = processPunctuationCommands(in: result)

        // Process format commands
        result = processFormatCommands(in: result)

        // Clean up any artifacts
        result = cleanup(result)

        return result
    }

    // MARK: - Private Methods

    /// Process punctuation commands
    private static func processPunctuationCommands(in text: String) -> String {
        var result = text

        for (patterns, replacement) in punctuationCommands {
            for pattern in patterns {
                // Match the command with optional surrounding spaces
                // Use word boundaries for English commands
                let regexPattern: String
                if pattern.range(of: "\\p{Han}", options: .regularExpression) != nil {
                    // Chinese pattern - no word boundaries needed
                    regexPattern = "\\s*\(NSRegularExpression.escapedPattern(for: pattern))\\s*"
                } else {
                    // English pattern - use word boundaries
                    regexPattern = "\\s*\\b\(NSRegularExpression.escapedPattern(for: pattern))\\b\\s*"
                }

                if let regex = try? NSRegularExpression(pattern: regexPattern, options: [.caseInsensitive]) {
                    let range = NSRange(result.startIndex..., in: result)
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
                }
            }
        }

        return result
    }

    /// Process format commands
    private static func processFormatCommands(in text: String) -> String {
        var result = text

        for (patterns, action) in formatCommands {
            for pattern in patterns {
                let regexPattern: String
                if pattern.range(of: "\\p{Han}", options: .regularExpression) != nil {
                    regexPattern = "\\s*\(NSRegularExpression.escapedPattern(for: pattern))\\s*"
                } else {
                    regexPattern = "\\s*\\b\(NSRegularExpression.escapedPattern(for: pattern))\\b\\s*"
                }

                if let regex = try? NSRegularExpression(pattern: regexPattern, options: [.caseInsensitive]) {
                    let range = NSRange(result.startIndex..., in: result)
                    result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: action.replacement)
                }
            }
        }

        return result
    }

    /// Clean up any artifacts from command processing
    private static func cleanup(_ text: String) -> String {
        var result = text

        // Remove multiple consecutive spaces
        if let regex = try? NSRegularExpression(pattern: " {2,}", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: " ")
        }

        // Remove space before Chinese punctuation
        if let regex = try? NSRegularExpression(pattern: " +([。，、！？：；」』）])", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Remove space after Chinese opening punctuation
        if let regex = try? NSRegularExpression(pattern: "([「『（]) +", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        return result.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Convenience Extension

extension String {
    /// Returns this string with voice commands processed
    var withVoiceCommandsProcessed: String {
        VoiceCommandProcessor.process(self)
    }
}
