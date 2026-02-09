import Foundation
import AppKit

/// Service that provides context-aware text refinement based on the active application
@MainActor
public class ContextAwareRefinementService: ObservableObject {
    public static let shared = ContextAwareRefinementService()

    // MARK: - Settings

    @Published public var isEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "ContextAwareRefinementEnabled")
        }
    }

    @Published public var customAppStyles: [String: AppStyle] = [:] {
        didSet {
            saveCustomStyles()
        }
    }

    private let customStylesKey = "ContextAwareCustomStyles"

    // MARK: - App Style Definitions

    public enum AppStyle: String, Codable, CaseIterable {
        case formal = "formal"
        case casual = "casual"
        case technical = "technical"
        case creative = "creative"
        case neutral = "neutral"

        public var displayName: String {
            switch self {
            case .formal: return "Formal"
            case .casual: return "Casual"
            case .technical: return "Technical"
            case .creative: return "Creative"
            case .neutral: return "Neutral"
            }
        }

        public var description: String {
            switch self {
            case .formal: return "Professional, polished language for business contexts"
            case .casual: return "Relaxed, conversational tone for messaging"
            case .technical: return "Precise, technical language preserving jargon"
            case .creative: return "Expressive language for creative writing"
            case .neutral: return "Standard refinement without style adjustment"
            }
        }

        public var icon: String {
            switch self {
            case .formal: return "briefcase"
            case .casual: return "bubble.left.and.bubble.right"
            case .technical: return "wrench.and.screwdriver"
            case .creative: return "paintbrush"
            case .neutral: return "equal.circle"
            }
        }

        /// Returns a prompt modifier for this style
        public var promptModifier: String {
            switch self {
            case .formal:
                return """
                Use formal, professional language. Ensure proper grammar and punctuation.
                Avoid contractions, slang, and overly casual expressions.
                Maintain a respectful and polished tone suitable for business communication.
                """
            case .casual:
                return """
                Use casual, friendly language. Contractions are fine.
                Keep the tone conversational and approachable.
                Emoji usage is acceptable if contextually appropriate.
                """
            case .technical:
                return """
                Preserve technical terminology and jargon exactly as spoken.
                Maintain precision in descriptions. Format code-related terms appropriately.
                Keep the language clear and unambiguous.
                """
            case .creative:
                return """
                Allow for expressive and varied language.
                Preserve unique phrasing and creative expressions.
                Maintain the speaker's voice and style.
                """
            case .neutral:
                return """
                Apply standard text refinement without adjusting the overall tone or style.
                Focus on clarity and correctness.
                """
            }
        }
    }

    // MARK: - Default App Mappings

    /// Default style mappings for common applications
    private let defaultAppStyles: [String: AppStyle] = [
        // Email clients - formal
        "com.apple.mail": .formal,
        "com.microsoft.Outlook": .formal,
        "com.google.Gmail": .formal,
        "com.readdle.smartemail-Mac": .formal,

        // Messaging apps - casual
        "com.tencent.xinWeChat": .casual,
        "com.apple.MobileSMS": .casual,
        "com.apple.iChat": .casual,
        "com.facebook.Messenger": .casual,
        "com.slack.Slack": .casual,
        "com.hnc.Discord": .casual,
        "org.telegram.desktop": .casual,
        "com.whatsapp.WhatsApp": .casual,

        // Development tools - technical
        "com.apple.dt.Xcode": .technical,
        "com.microsoft.VSCode": .technical,
        "com.sublimetext.4": .technical,
        "com.jetbrains.intellij": .technical,
        "com.googlecode.iterm2": .technical,
        "com.apple.Terminal": .technical,

        // Writing/Notes - neutral
        "com.apple.Notes": .neutral,
        "com.apple.TextEdit": .neutral,
        "md.obsidian": .neutral,
        "com.notion.id": .neutral,

        // Creative apps - creative
        "com.ulyssesapp.mac": .creative,
        "com.literatureandlatte.scrivener3": .creative,
    ]

    // MARK: - Initialization

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "ContextAwareRefinementEnabled")
        loadCustomStyles()
    }

    // MARK: - Public API

    /// Get the current frontmost application's bundle identifier
    public func getCurrentAppBundleId() -> String? {
        return NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    /// Get the current frontmost application's name
    public func getCurrentAppName() -> String? {
        return NSWorkspace.shared.frontmostApplication?.localizedName
    }

    /// Get the style for the current frontmost application
    public func getStyleForCurrentApp() -> AppStyle {
        guard isEnabled else { return .neutral }

        guard let bundleId = getCurrentAppBundleId() else {
            return .neutral
        }

        return getStyle(for: bundleId)
    }

    /// Get the style for a specific bundle identifier
    public func getStyle(for bundleId: String) -> AppStyle {
        // Check custom styles first
        if let customStyle = customAppStyles[bundleId] {
            return customStyle
        }

        // Fall back to defaults
        if let defaultStyle = defaultAppStyles[bundleId] {
            return defaultStyle
        }

        return .neutral
    }

    /// Set a custom style for an application
    public func setStyle(_ style: AppStyle, for bundleId: String) {
        customAppStyles[bundleId] = style
    }

    /// Remove custom style (revert to default)
    public func removeCustomStyle(for bundleId: String) {
        customAppStyles.removeValue(forKey: bundleId)
    }

    /// Generate a refinement prompt that includes context-aware style instructions
    public func generateContextAwarePrompt(basePrompt: String) -> String {
        guard isEnabled else { return basePrompt }

        let style = getStyleForCurrentApp()
        let appName = getCurrentAppName() ?? "unknown app"

        return """
        \(basePrompt)

        Context: The user is dictating into \(appName).
        Style guidance: \(style.promptModifier)
        """
    }

    /// Get all known applications with their styles
    public func getAllKnownApps() -> [(bundleId: String, style: AppStyle, isCustom: Bool)] {
        var result: [(String, AppStyle, Bool)] = []

        // Add defaults
        for (bundleId, style) in defaultAppStyles {
            let isCustom = customAppStyles[bundleId] != nil
            let effectiveStyle = customAppStyles[bundleId] ?? style
            result.append((bundleId, effectiveStyle, isCustom))
        }

        // Add custom-only entries
        for (bundleId, style) in customAppStyles where defaultAppStyles[bundleId] == nil {
            result.append((bundleId, style, true))
        }

        return result.sorted { $0.0 < $1.0 }
    }

    // MARK: - Persistence

    private func saveCustomStyles() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(customAppStyles) {
            UserDefaults.standard.set(data, forKey: customStylesKey)
        }
    }

    private func loadCustomStyles() {
        guard let data = UserDefaults.standard.data(forKey: customStylesKey) else { return }

        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode([String: AppStyle].self, from: data) {
            customAppStyles = loaded
        }
    }
}
