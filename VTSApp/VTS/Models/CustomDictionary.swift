import Foundation

/// Represents a custom dictionary entry
public struct DictionaryEntry: Codable, Identifiable, Equatable {
    public let id: UUID
    public var term: String
    public var pronunciation: String? // Optional phonetic hint
    public var category: EntryCategory
    public var createdAt: Date

    public init(term: String, pronunciation: String? = nil, category: EntryCategory = .general) {
        self.id = UUID()
        self.term = term
        self.pronunciation = pronunciation
        self.category = category
        self.createdAt = Date()
    }

    public enum EntryCategory: String, Codable, CaseIterable {
        case general = "General"
        case name = "Name"
        case brand = "Brand"
        case technical = "Technical"
        case medical = "Medical"
        case legal = "Legal"
        case custom = "Custom"

        public var icon: String {
            switch self {
            case .general: return "doc.text"
            case .name: return "person"
            case .brand: return "building.2"
            case .technical: return "wrench.and.screwdriver"
            case .medical: return "cross.case"
            case .legal: return "scale.3d"
            case .custom: return "star"
            }
        }
    }
}

/// Manages the user's custom dictionary for improved transcription accuracy
@MainActor
public class CustomDictionaryManager: ObservableObject {
    public static let shared = CustomDictionaryManager()

    private let storageKey = "CustomDictionaryEntries"

    @Published public var entries: [DictionaryEntry] = [] {
        didSet {
            saveEntries()
        }
    }

    @Published public var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "CustomDictionaryEnabled")
        }
    }

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "CustomDictionaryEnabled")
        loadEntries()
    }

    // MARK: - Public API

    /// Add a new term to the dictionary
    public func addEntry(_ term: String, pronunciation: String? = nil, category: DictionaryEntry.EntryCategory = .general) {
        let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTerm.isEmpty else { return }

        // Check for duplicates
        guard !entries.contains(where: { $0.term.lowercased() == trimmedTerm.lowercased() }) else {
            return
        }

        let entry = DictionaryEntry(term: trimmedTerm, pronunciation: pronunciation, category: category)
        entries.append(entry)
    }

    /// Remove an entry from the dictionary
    public func removeEntry(_ entry: DictionaryEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    /// Remove entries at specified indices
    public func removeEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }

    /// Update an existing entry
    public func updateEntry(_ entry: DictionaryEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
    }

    /// Get all terms as a comma-separated string for use in prompts
    public func getTermsForPrompt() -> String? {
        guard isEnabled, !entries.isEmpty else { return nil }

        let terms = entries.map { entry in
            if let pronunciation = entry.pronunciation, !pronunciation.isEmpty {
                return "\(entry.term) (\(pronunciation))"
            }
            return entry.term
        }

        return terms.joined(separator: ", ")
    }

    /// Get terms grouped by category
    public func getTermsByCategory() -> [DictionaryEntry.EntryCategory: [DictionaryEntry]] {
        Dictionary(grouping: entries, by: { $0.category })
    }

    /// Generate a context string for LLM refinement
    public func generateContextForRefinement() -> String? {
        guard isEnabled, !entries.isEmpty else { return nil }

        var context = "Custom vocabulary to preserve exactly as written:\n"

        let groupedEntries = getTermsByCategory()
        for (category, categoryEntries) in groupedEntries.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let terms = categoryEntries.map { $0.term }.joined(separator: ", ")
            context += "- \(category.rawValue): \(terms)\n"
        }

        return context
    }

    // MARK: - Import/Export

    /// Export dictionary as JSON
    public func exportToJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(entries)
    }

    /// Import dictionary from JSON
    public func importFromJSON(_ data: Data, merge: Bool = true) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let importedEntries = try decoder.decode([DictionaryEntry].self, from: data)

        if merge {
            // Merge with existing entries, avoiding duplicates
            for entry in importedEntries {
                if !entries.contains(where: { $0.term.lowercased() == entry.term.lowercased() }) {
                    entries.append(entry)
                }
            }
        } else {
            entries = importedEntries
        }
    }

    /// Clear all entries
    public func clearAll() {
        entries.removeAll()
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
        if let loaded = try? decoder.decode([DictionaryEntry].self, from: data) {
            entries = loaded
        }
    }
}
