import Foundation

/// Provider implementation for BigModel (Zhipu AI) API
class BigModelProvider: RestSTTProvider {
    var providerType: STTProviderType { .bigmodel }

    // Base URL for BigModel API
    private let baseURL = "https://api.z.ai/api/paas/v4"

    func validateConfig(_ config: ProviderConfig) throws {
        guard !config.apiKey.isEmpty else {
            throw STTError.invalidAPIKey
        }
    }

    func transcribe(stream: AsyncThrowingStream<Data, Error>, config: ProviderConfig) async throws -> String {
        // Collect audio data
        var audioData = Data()
        for try await chunk in stream {
            audioData.append(chunk)
        }
        
        // Add WAV header
        let header = createWavHeader(dataSize: audioData.count)
        var fullAudioData = header
        fullAudioData.append(audioData)

        // Prepare the request
        let url = URL(string: "\(baseURL)/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        // Generate boundary for multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create the body
        var body = Data()

        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(fullAudioData)
        body.append("\r\n".data(using: .utf8)!)

        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(config.model)\r\n".data(using: .utf8)!)

        // Add system prompt if available
        if let systemPrompt = config.systemPrompt, !systemPrompt.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(systemPrompt)\r\n".data(using: .utf8)!)
        }

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw STTError.networkError("Invalid response")
        }

        if httpResponse.statusCode != 200 {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw STTError.transcriptionError("API Error (\(httpResponse.statusCode)): \(errorMsg)")
        }

        // Parse response
        struct OpenAIResponse: Codable {
            let text: String
        }

        do {
            let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            return result.text
        } catch {
            throw STTError.transcriptionError("Failed to decode response: \(error.localizedDescription)")
        }
    }
    
    private func createWavHeader(dataSize: Int) -> Data {
        let sampleRate: Int32 = 24000
        let channels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate = sampleRate * Int32(channels * bitsPerSample / 8)
        let blockAlign = channels * bitsPerSample / 8
        
        var header = Data()
        
        header.append("RIFF".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(36 + dataSize).littleEndian) { Data($0) })
        header.append("WAVE".data(using: .ascii)!)
        
        header.append("fmt ".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) }) // PCM
        header.append(withUnsafeBytes(of: channels.littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: sampleRate.littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        header.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
        
        header.append("data".data(using: .ascii)!)
        header.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        return header
    }
}
