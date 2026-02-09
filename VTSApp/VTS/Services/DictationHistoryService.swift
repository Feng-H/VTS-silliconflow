import Foundation

/// Represents a single dictation history entry
public struct DictationHistoryEntry: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let originalText: String
    public let refinedText: String?
    public let targetAppBundleId: String?
    public let targetAppName: String?
    public let duration: TimeInterval? // Audio duration in seconds
    public let provider: String?

    public init(
        originalText: String,
        refinedText: String? = nil,
        targetAppBundleId: String? = nil,
        targetAppName: String? = nil,
        duration: TimeInterval? = nil,
        provider: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.originalText = originalText
        self.refinedText = refinedText
        self.targetAppBundleId = targetAppBundleId
        self.targetAppName = targetAppName
        self.duration = duration
        self.provider = provider
    }

    /// The final text that was injected (refined if available, otherwise original)
    public var finalText: String {
        refinedText ?? originalText
    }

    /// Whether refinement was applied
    public var wasRefined: Bool {
        refinedText != nil && refinedText != originalText
    }
}

/// Service for managing dictation history
@MainActor
public class DictationHistoryService: ObservableObject {
    public static let shared = DictationHistoryService()

    // MARK: - Settings

    @Published public var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "DictationHistoryEnabled")
        }
    }

    @Published public var maxEntries: Int = 100 {
        didSet {
            UserDefaults.standard.set(maxEntries, forKey: "DictationHistoryMaxEntries")
            trimToMaxEntries()
        }
    }

    @Published public private(set) var entries: [DictationHistoryEntry] = []

    private let storageKey = "DictationHistoryEntries"

    // MARK: - Initialization

    private init() {
        self.isEnabled = UserDefaults.standard.object(forKey: "DictationHistoryEnabled") as? Bool ?? true
        self.maxEntries = UserDefaults.standard.object(forKey: "DictationHistoryMaxEntries") as? Int ?? 100
        loadEntries()
    }

    // MARK: - Public API

    /// Add a new dictation entry to history
    public func addEntry(
        originalText: String,
        refinedText: String? = nil,
        targetAppBundleId: String? = nil,
        targetAppName: String? = nil,
        duration: TimeInterval? = nil,
        provider: String? = nil
    ) {
        guard isEnabled else { return }
        guard !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let entry = DictationHistoryEntry(
            originalText: originalText,
            refinedText: refinedText,
            targetAppBundleId: targetAppBundleId,
            targetAppName: targetAppName,
            duration: duration,
            provider: provider
        )

        entries.insert(entry, at: 0)
        trimToMaxEntries()
        saveEntries()
    }

    /// Get recent entries (default: last 10)
    public func getRecentEntries(limit: Int = 10) -> [DictationHistoryEntry] {
        Array(entries.prefix(limit))
    }

    /// Get entries for a specific date
    public func getEntries(for date: Date) -> [DictationHistoryEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }

    /// Get entries within a date range
    public func getEntries(from startDate: Date, to endDate: Date) -> [DictationHistoryEntry] {
        entries.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    /// Search entries by text content
    public func search(query: String) -> [DictationHistoryEntry] {
        let lowercasedQuery = query.lowercased()
        return entries.filter {
            $0.originalText.lowercased().contains(lowercasedQuery) ||
            ($0.refinedText?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }

    /// Delete a specific entry
    public func deleteEntry(_ entry: DictationHistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    /// Delete entries at specified indices
    public func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    /// Clear all history
    public func clearAll() {
        entries.removeAll()
        saveEntries()
    }

    /// Get statistics
    public func getStatistics() -> HistoryStatistics {
        let totalEntries = entries.count
        let refinedCount = entries.filter { $0.wasRefined }.count
        let totalDuration = entries.compactMap { $0.duration }.reduce(0, +)
        let totalCharacters = entries.reduce(0) { $0 + $1.finalText.count }

        // Group by app
        var appUsage: [String: Int] = [:]
        for entry in entries {
            let appName = entry.targetAppName ?? "Unknown"
            appUsage[appName, default: 0] += 1
        }

        // Group by day (last 7 days)
        let calendar = Calendar.current
        var dailyUsage: [Date: Int] = [:]
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        for entry in entries where entry.timestamp >= sevenDaysAgo {
            let day = calendar.startOfDay(for: entry.timestamp)
            dailyUsage[day, default: 0] += 1
        }

        return HistoryStatistics(
            totalEntries: totalEntries,
            refinedCount: refinedCount,
            totalDuration: totalDuration,
            totalCharacters: totalCharacters,
            appUsage: appUsage,
            dailyUsage: dailyUsage
        )
    }

    // MARK: - Export

    /// Export history as JSON
    public func exportToJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(entries)
    }

    /// Export history as CSV
    public func exportToCSV() -> String {
        var csv = "Timestamp,Original Text,Refined Text,App,Duration\n"

        let dateFormatter = ISO8601DateFormatter()

        for entry in entries {
            let timestamp = dateFormatter.string(from: entry.timestamp)
            let original = escapeCSV(entry.originalText)
            let refined = escapeCSV(entry.refinedText ?? "")
            let app = escapeCSV(entry.targetAppName ?? "")
            let duration = entry.duration.map { String(format: "%.1f", $0) } ?? ""

            csv += "\(timestamp),\(original),\(refined),\(app),\(duration)\n"
        }

        return csv
    }

    private func escapeCSV(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            return "\"\(escaped)\""
        }
        return escaped
    }

    // MARK: - Persistence

    private func saveEntries() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let loaded = try? decoder.decode([DictationHistoryEntry].self, from: data) {
            entries = loaded
        }
    }

    private func trimToMaxEntries() {
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
    }
}

// MARK: - Statistics Model

public struct HistoryStatistics {
    public let totalEntries: Int
    public let refinedCount: Int
    public let totalDuration: TimeInterval
    public let totalCharacters: Int
    public let appUsage: [String: Int]
    public let dailyUsage: [Date: Int]

    public var refinementRate: Double {
        guard totalEntries > 0 else { return 0 }
        return Double(refinedCount) / Double(totalEntries)
    }

    public var averageCharactersPerEntry: Double {
        guard totalEntries > 0 else { return 0 }
        return Double(totalCharacters) / Double(totalEntries)
    }

    public var topApps: [(name: String, count: Int)] {
        appUsage.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
}
