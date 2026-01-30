import Foundation

public struct TranscriptionChunk {
    public let text: String
    public let isFinal: Bool
    public let timestamp: Date
    
    public init(text: String, isFinal: Bool = false, timestamp: Date = Date()) {
        self.text = text
        self.isFinal = isFinal
        self.timestamp = timestamp
    }
}

public struct TranscriptionResult {
    public let text: String
    public let isFinal: Bool

    public init(text: String, isFinal: Bool) {
        self.text = text
        self.isFinal = isFinal
    }
}

public struct ProviderConfig {
    public let apiKey: String
    public let model: String
    public let systemPrompt: String?
    public let language: String?
    public let temperature: Float?
    public let keywords: [String]?
    
    public init(apiKey: String, model: String, systemPrompt: String? = nil, language: String? = nil, temperature: Float? = nil, keywords: [String]? = nil) {
        self.apiKey = apiKey
        self.model = model
        self.systemPrompt = systemPrompt
        self.language = language
        self.temperature = temperature
        self.keywords = keywords
    }
}

public enum STTProviderType: String, CaseIterable, Codable {
    case siliconflow = "SiliconFlow"
    case bigmodel = "BigModel"

    public var restModels: [String] {
        switch self {
        case .siliconflow:
            // FunAudioLLM/SenseVoiceSmall is the verified model for the transcriptions endpoint
            return ["TeleAI/TeleSpeechASR", "FunAudioLLM/SenseVoiceSmall"]
        case .bigmodel:
            // glm-asr-2512 is the dedicated ASR model name
            return ["glm-asr-2512"]
        }
    }

    public var realtimeModels: [String] {
        switch self {
        case .siliconflow, .bigmodel:
            return [] // Future support
        }
    }

    /// Returns all available models (both REST and real-time)
    public var allModels: [String] {
        return restModels + realtimeModels
    }

    /// Checks if a model supports real-time streaming
    public func supportsRealtime(_ model: String) -> Bool {
        return realtimeModels.contains(model)
    }

    /// Checks if the provider supports real-time streaming at all
    public var supportsRealtimeStreaming: Bool {
        return !realtimeModels.isEmpty
    }
}