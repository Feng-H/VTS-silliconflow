import Foundation

/// Protocol for providers that can refine/post-process transcribed text
public protocol TextRefinementProvider {
    /// Refines the input text based on the system prompt
    /// - Parameters:
    ///   - text: The input text to refine
    ///   - systemPrompt: The system instructions for refinement
    ///   - config: The provider configuration (API key, etc.)
    /// - Returns: The refined text
    func refine(text: String, systemPrompt: String, config: ProviderConfig) async throws -> String

    /// Validates the provider configuration
    func validateConfig(_ config: ProviderConfig) throws
}
