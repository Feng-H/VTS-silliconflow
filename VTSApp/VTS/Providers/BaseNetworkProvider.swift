import Foundation

/// Base class for network providers that provides common functionality
/// with retry logic and configurable timeouts
public class BaseNetworkProvider {

    // Network configuration
    public let maxRetries = 3
    public let baseRetryDelay: TimeInterval = 1.0 // seconds

    public init() {}

    /// Performs a network request with retry logic and configurable timeout
    /// - Parameters:
    ///   - request: The URLRequest to perform
    ///   - timeout: The timeout interval for the request
    ///   - label: A label for logging purposes (e.g. provider name)
    /// - Returns: The data and response
    public func performNetworkRequest(
        request: URLRequest,
        timeout: TimeInterval,
        label: String
    ) async throws -> (Data, URLResponse) {

        // Configure URLSession with calculated timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: config)

        var lastError: Error?

        // Retry loop
        for attempt in 1...maxRetries {
            do {
                print("\(label): Attempt \(attempt)/\(maxRetries) - sending request...")
                let (data, response) = try await session.data(for: request)

                print("\(label): Successfully received response on attempt \(attempt)")
                return (data, response)

            } catch {
                lastError = error
                let isRetryable = isNetworkErrorRetryable(error)

                print("\(label): Attempt \(attempt) failed with error: \(error)")

                // Don't retry if it's not a network error or if this was the last attempt
                if !isRetryable || attempt == maxRetries {
                    print("\(label): Error is not retryable or max attempts reached")
                    break
                }

                // Calculate delay with exponential backoff
                let delaySeconds = baseRetryDelay * pow(2.0, Double(attempt - 1))
                print("\(label): Retrying in \(delaySeconds)s...")

                try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
            }
        }

        // If we get here, all retries failed
        if let lastError = lastError {
            throw STTError.networkError("Network request failed after \(maxRetries) attempts: \(lastError.localizedDescription)")
        } else {
            throw STTError.networkError("Network request failed after \(maxRetries) attempts")
        }
    }

    /// Determines if an error is retryable (network/timeout errors)
    public func isNetworkErrorRetryable(_ error: Error) -> Bool {
        // Check for NSURLError cases that are typically retryable
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut,                    // Request timed out
                 .cannotConnectToHost,         // Cannot connect to host
                 .networkConnectionLost,       // Network connection lost
                 .cannotFindHost,             // Cannot find host
                 .dnsLookupFailed,            // DNS lookup failed
                 .notConnectedToInternet,     // Not connected to internet
                 .badServerResponse,          // Bad server response
                 .cannotLoadFromNetwork:      // Cannot load from network
                return true
            default:
                return false
            }
        }

        // Check for general network errors
        if let nsError = error as NSError? {
            // CFNetwork errors
            if nsError.domain == "kCFErrorDomainCFNetwork" {
                return true
            }
            // NSURLError domain (backup check)
            if nsError.domain == NSURLErrorDomain {
                return true
            }
        }

        return false
    }
}
