import Foundation

/// A text refinement provider compatible with OpenAI's chat completions API
/// Works with OpenAI, SiliconFlow, DeepSeek, etc.
public class OpenAICompatibleRefinementProvider: BaseNetworkProvider, TextRefinementProvider {

    // Configurable model name (defaults to Qwen/Qwen2.5-7B-Instruct for SiliconFlow if not specified)
    private var modelName: String

    public init(modelName: String = "Qwen/Qwen2.5-7B-Instruct") {
        self.modelName = modelName
        super.init()
    }

    public func validateConfig(_ config: ProviderConfig) throws {
        guard !config.apiKey.isEmpty else {
            throw STTError.invalidConfig("API key is missing")
        }
        guard let _ = URL(string: config.baseUrl) else {
            throw STTError.invalidConfig("Invalid API URL")
        }
    }

    public func refine(text: String, systemPrompt: String, config: ProviderConfig) async throws -> String {
        guard let url = URL(string: config.baseUrl) else {
            throw STTError.invalidConfig("Invalid API URL")
        }

        // Prepare the request body
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": text]
        ]

        let requestBody: [String: Any] = [
            "model": config.model.isEmpty ? modelName : config.model,
            "messages": messages,
            "temperature": 0.3, // Low temperature for deterministic refinement
            "stream": false
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        // Use a short timeout for refinement (it should be fast)
        // 10 seconds should be enough for post-processing short dictation
        let timeout: TimeInterval = 10.0

        let (data, response) = try await performNetworkRequest(
            request: request,
            timeout: timeout,
            label: "TextRefinement"
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw STTError.networkError("Invalid response type")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Refinement Error response: \(errorJson)")
            }
            throw STTError.networkError("Server returned status code \(httpResponse.statusCode)")
        }

        // Parse response
        struct ChatCompletionResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        do {
            let result = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            guard let content = result.choices.first?.message.content else {
                throw STTError.decodingError("No content in response")
            }
            return content
        } catch {
            print("Decoding error: \(error)")
            throw STTError.decodingError("Failed to decode response: \(error.localizedDescription)")
        }
    }
}
