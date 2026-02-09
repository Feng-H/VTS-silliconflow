import Foundation

/// Supported language options for speech recognition
public enum RecognitionLanguage: String, CaseIterable, Codable {
    case auto = "auto"
    case chinese = "zh"
    case english = "en"
    case chineseEnglish = "zh-en"
    case japanese = "ja"
    case korean = "ko"

    public var displayName: String {
        switch self {
        case .auto:
            return "Auto Detect"
        case .chinese:
            return "Chinese (中文)"
        case .english:
            return "English"
        case .chineseEnglish:
            return "Chinese-English Mix (中英混合)"
        case .japanese:
            return "Japanese (日本語)"
        case .korean:
            return "Korean (한국어)"
        }
    }

    public var description: String {
        switch self {
        case .auto:
            return "Automatically detect the spoken language"
        case .chinese:
            return "Optimized for Mandarin Chinese"
        case .english:
            return "Optimized for English"
        case .chineseEnglish:
            return "For mixed Chinese and English speech"
        case .japanese:
            return "Optimized for Japanese"
        case .korean:
            return "Optimized for Korean"
        }
    }

    /// Returns the language code to pass to the API
    /// Some providers use different codes, so this can be customized per provider
    public func apiCode(for provider: STTProviderType) -> String? {
        switch self {
        case .auto:
            return nil // Let provider auto-detect
        case .chinese:
            return "zh"
        case .english:
            return "en"
        case .chineseEnglish:
            // Different providers may handle this differently
            switch provider {
            case .siliconflow:
                return "zh" // SenseVoice handles mixed automatically
            case .bigmodel:
                return "zh" // GLM handles mixed automatically
            case .openai:
                return nil // Whisper auto-detects well
            }
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        }
    }
}

/// Manager for language settings
public class LanguageSettingsManager: ObservableObject {
    public static let shared = LanguageSettingsManager()

    private let languageKey = "RecognitionLanguage"

    @Published public var selectedLanguage: RecognitionLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: languageKey)
        }
    }

    private init() {
        if let savedValue = UserDefaults.standard.string(forKey: languageKey),
           let language = RecognitionLanguage(rawValue: savedValue) {
            self.selectedLanguage = language
        } else {
            self.selectedLanguage = .auto
        }
    }

    /// Get the language code for a specific provider
    public func getLanguageCode(for provider: STTProviderType) -> String? {
        return selectedLanguage.apiCode(for: provider)
    }
}
