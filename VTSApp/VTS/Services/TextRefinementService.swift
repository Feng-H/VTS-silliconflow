import Foundation
import Combine
import AppKit

/// Service to handle text refinement/post-processing
@MainActor
public class TextRefinementService: ObservableObject {

    // MARK: - Published Properties
    @Published public var isRefinementEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isRefinementEnabled, forKey: "RefinementEnabled")
        }
    }

    @Published public var systemPrompt: String = "You are a text cleaner. Remove filler words (um, ah, like), fix self-corrections, and format the text properly. Do not change the meaning. Return ONLY the refined text." {
        didSet {
            UserDefaults.standard.set(systemPrompt, forKey: "RefinementSystemPrompt")
        }
    }

    @Published public var selectedModel: String = "Qwen/Qwen2.5-7B-Instruct" {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "RefinementModel")
        }
    }

    @Published public private(set) var isRefining: Bool = false

    // MARK: - Private Properties
    private let provider = OpenAICompatibleRefinementProvider()
    private let apiKeyManager = APIKeyManager()

    private var refinementConfig: ProviderConfig? {
        if let key = try? apiKeyManager.getAPIKey(for: .siliconflow) {
            return ProviderConfig(
                apiKey: key,
                baseUrl: "https://api.siliconflow.cn/v1/chat/completions",
                model: selectedModel
            )
        }
        if let key = try? apiKeyManager.getAPIKey(for: .openai) {
            return ProviderConfig(
                apiKey: key,
                baseUrl: "https://api.openai.com/v1/chat/completions",
                model: "gpt-3.5-turbo"
            )
        }
        return nil
    }

    public init() {
        self.isRefinementEnabled = UserDefaults.standard.bool(forKey: "RefinementEnabled")
        if let savedPrompt = UserDefaults.standard.string(forKey: "RefinementSystemPrompt") {
            self.systemPrompt = savedPrompt
        }
        if let savedModel = UserDefaults.standard.string(forKey: "RefinementModel") {
            self.selectedModel = savedModel
        }
    }

    // MARK: - Environment Awareness

    private enum AppContext: String {
        case code = "Coding/Development"
        case chat = "Messaging/Chat"
        case writing = "Professional Writing/Mail"
        case general = "General"

        var specializedPrompt: String {
            switch self {
            case .code:
                return "The user is coding. Keep all technical terms, variable names, and code snippets exactly as they are. Fix typos only in comments or natural language parts."
            case .chat:
                return "The user is in a chat application. Keep the tone natural and informal. Remove only obvious hesitations and repeated words."
            case .writing:
                return "The user is writing a formal document or email. Use a professional tone, correct grammar, and improve flow while maintaining the original meaning."
            case .general:
                return "Refine the text by removing filler words and fixing minor grammar issues."
            }
        }
    }

    private func getActiveAppContext() -> (name: String, context: AppContext) {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return ("Unknown", .general)
        }
        
        let bundleId = app.bundleIdentifier ?? ""
        let appName = app.localizedName ?? "Unknown"
        
        if bundleId.contains("xcode") || bundleId.contains("vscode") || bundleId.contains("intellij") || bundleId.contains("terminal") || bundleId.contains("iterm") {
            return (appName, .code)
        } else if bundleId.contains("wechat") || bundleId.contains("slack") || bundleId.contains("discord") || bundleId.contains("whatsapp") || bundleId.contains("telegram") || bundleId.contains("messenger") {
            return (appName, .chat)
        } else if bundleId.contains("mail") || bundleId.contains("pages") || bundleId.contains("notes") || bundleId.contains("word") || bundleId.contains("outlook") {
            return (appName, .writing)
        }
        
        return (appName, .general)
    }

    // MARK: - Public API

    /// Refines the given text if enabled and configured
    public func refine(_ text: String) async -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return text
        }

        var processedText = text

        // Step 1: Apply lightweight filler word filter
        if FillerWordFilter.isEnabled {
            processedText = FillerWordFilter.filter(processedText)
        }

        // Step 2: If LLM refinement is disabled, return after filler filter
        guard isRefinementEnabled else {
            return processedText
        }

        // Quick Exit: If text is extremely short after filtering, don't bother LLM
        if processedText.count < 3 {
            return processedText
        }

        guard let config = refinementConfig else {
            print("⚠️ TextRefinementService: No API key available for refinement")
            return processedText
        }

        isRefining = true
        defer { isRefining = false }

        let appInfo = getActiveAppContext()
        let dynamicSystemPrompt = """
        \(systemPrompt)
        
        Context: The user is currently using "\(appInfo.name)".
        Scenario Recommendation: \(appInfo.context.specializedPrompt)
        """

        print("✨ TextRefinementService: Refining for \(appInfo.name) (\(appInfo.context.rawValue))")

        do {
            let refinedText = try await provider.refine(
                text: processedText,
                systemPrompt: dynamicSystemPrompt,
                config: config
            )
            return refinedText.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("⚠️ TextRefinementService: Refinement failed: \(error)")
            return processedText
        }
    }
}
