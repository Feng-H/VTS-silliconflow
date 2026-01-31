import Foundation

public protocol RestSTTProvider {
    var providerType: STTProviderType { get }
    
    func transcribe(
        stream: AsyncThrowingStream<Data, Error>,
        config: ProviderConfig
    ) async throws -> String
    
    func validateConfig(_ config: ProviderConfig) throws
}

public enum STTError: Error, LocalizedError, Equatable {
    case invalidAPIKey
    case invalidModel
    case invalidConfig(String)
    case decodingError(String)
    case networkError(String)
    case audioProcessingError(String)
    case transcriptionError(String)

    public static func == (lhs: STTError, rhs: STTError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidAPIKey, .invalidAPIKey),
             (.invalidModel, .invalidModel):
            return true
        case (.invalidConfig(let lhsMessage), .invalidConfig(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.decodingError(let lhsMessage), .decodingError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError == rhsError
        case (.audioProcessingError(let lhsMessage), .audioProcessingError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.transcriptionError(let lhsMessage), .transcriptionError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .invalidModel:
            return "Invalid model specified"
        case .invalidConfig(let message):
            return "Invalid configuration: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let error):
            return "Network error: \(error)"
        case .audioProcessingError(let message):
            return "Audio processing error: \(message)"
        case .transcriptionError(let message):
            return "Transcription error: \(message)"
        }
    }
}