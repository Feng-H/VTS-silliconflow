import Foundation

/// Base class for REST STT providers that provides common networking functionality
/// with retry logic and configurable timeouts
public class BaseRestSTTProvider: BaseNetworkProvider, RestSTTProvider {
    public var providerType: STTProviderType {
        fatalError("Must be implemented by subclass")
    }

    // Timeout configuration based on audio size
    private func calculateTimeout(for audioDataSize: Int) -> TimeInterval {
        // Base timeout of 30 seconds
        let baseTimeout: TimeInterval = 30.0

        // Add extra time based on audio size
        // ~1MB of audio = ~1 minute of speech, add 15 seconds per MB
        let megabytes = Double(audioDataSize) / (1024 * 1024)
        let additionalTimeout = megabytes * 15.0

        // Cap maximum timeout at 120 seconds (2 minutes)
        return min(baseTimeout + additionalTimeout, 120.0)
    }

    // MARK: - RestSTTProvider Protocol Requirements (to be implemented by subclasses)

    public func transcribe(
        stream: AsyncThrowingStream<Data, Error>,
        config: ProviderConfig
    ) async throws -> String {
        fatalError("Must be implemented by subclass")
    }

    public func validateConfig(_ config: ProviderConfig) throws {
        fatalError("Must be implemented by subclass")
    }

    // MARK: - Protected Methods for Subclasses

    /// Performs a network request with retry logic and configurable timeout
    internal func performNetworkRequest(
        request: URLRequest,
        audioDataSize: Int,
        providerName: String
    ) async throws -> (Data, URLResponse) {
        let timeout = calculateTimeout(for: audioDataSize)
        print("\(providerName): Calculated timeout: \(timeout)s for audio size: \(audioDataSize) bytes")

        return try await super.performNetworkRequest(
            request: request,
            timeout: timeout,
            label: providerName
        )
    }

    /// Common WAV data creation method for all providers
    internal func createWAVData(from pcmData: Data) -> Data {
        let sampleRate: UInt32 = 24000
        let channels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = sampleRate * UInt32(channels) * UInt32(bitsPerSample) / 8
        let blockAlign = channels * bitsPerSample / 8
        let dataSize = UInt32(pcmData.count)
        let fileSize = 36 + dataSize
        
        var wavData = Data()
        
        // RIFF header
        wavData.append("RIFF".data(using: .ascii)!)
        var fileSizeLE = fileSize.littleEndian
        wavData.append(Data(bytes: &fileSizeLE, count: 4))
        wavData.append("WAVE".data(using: .ascii)!)
        
        // fmt chunk
        wavData.append("fmt ".data(using: .ascii)!)
        let fmtSize: UInt32 = 16
        var fmtSizeLE = fmtSize.littleEndian
        wavData.append(Data(bytes: &fmtSizeLE, count: 4))
        let audioFormat: UInt16 = 1 // PCM
        var audioFormatLE = audioFormat.littleEndian
        wavData.append(Data(bytes: &audioFormatLE, count: 2))
        var channelsLE = channels.littleEndian
        wavData.append(Data(bytes: &channelsLE, count: 2))
        var sampleRateLE = sampleRate.littleEndian
        wavData.append(Data(bytes: &sampleRateLE, count: 4))
        var byteRateLE = byteRate.littleEndian
        wavData.append(Data(bytes: &byteRateLE, count: 4))
        var blockAlignLE = blockAlign.littleEndian
        wavData.append(Data(bytes: &blockAlignLE, count: 2))
        var bitsPerSampleLE = bitsPerSample.littleEndian
        wavData.append(Data(bytes: &bitsPerSampleLE, count: 2))
        
        // data chunk
        wavData.append("data".data(using: .ascii)!)
        var dataSizeLE = dataSize.littleEndian
        wavData.append(Data(bytes: &dataSizeLE, count: 4))
        wavData.append(pcmData)
        
        return wavData
    }
} 