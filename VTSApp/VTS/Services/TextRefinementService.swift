import Foundation
import Combine

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

    // MARK: - Private Properties
    private let provider = OpenAICompatibleRefinementProvider()
    private let apiKeyManager = APIKeyManager() // We'll need access to API keys

    // We'll use SiliconFlow as the default backend for refinement as it's fast and cheap
    // ideally reusing the user's existing SiliconFlow key if available
    private var refinementConfig: ProviderConfig? {
        // Try to get SiliconFlow key first
        if let key = try? apiKeyManager.getAPIKey(for: .siliconflow) {
            return ProviderConfig(
                apiKey: key,
                baseUrl: "https://api.siliconflow.cn/v1/chat/completions",
                model: selectedModel
            )
        }

        // Fallback to OpenAI if available
        if let key = try? apiKeyManager.getAPIKey(for: .openai) {
            return ProviderConfig(
                apiKey: key,
                baseUrl: "https://api.openai.com/v1/chat/completions",
                model: "gpt-3.5-turbo" // Fallback model
            )
        }

        return nil
    }

    public init() {
        // Load settings
        self.isRefinementEnabled = UserDefaults.standard.bool(forKey: "RefinementEnabled")

        if let savedPrompt = UserDefaults.standard.string(forKey: "RefinementSystemPrompt") {
            self.systemPrompt = savedPrompt
        }

        if let savedModel = UserDefaults.standard.string(forKey: "RefinementModel") {
            self.selectedModel = savedModel
        }
    }

    /// Refines the given text if enabled and configured
    /// Returns the original text if refinement is disabled or fails
    public func refine(_ text: String) async -> String {
        guard isRefinementEnabled, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return text
        }

        guard let config = refinementConfig else {
            print("⚠️ TextRefinementService: No API key available for refinement")
            return text
        }

        print("✨ TextRefinementService: Refining text: '\(text)'")

        do {
            let refinedText = try await provider.refine(
                text: text,
                systemPrompt: systemPrompt,
                config: config
            )

            print("✨ TextRefinementService: Refinement success: '\(refinedText)'")
            return refinedText.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("⚠️ TextRefinementService: Refinement failed: \(error)")
            // Return original text on failure so the user still gets their dictation
            return text
        }
    }
}
