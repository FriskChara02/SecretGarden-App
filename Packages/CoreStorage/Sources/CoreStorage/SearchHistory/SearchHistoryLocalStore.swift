//
//  SearchHistoryLocalStore.swift
//  CoreStorage
//
//  Created by Loi Nguyen on 29/8/26.
//

// Local storage layer for search history, using SwiftData.
// Implemented as an actor because ModelContext is not thread-safe by default—the same reason
// KeychainManager is designed as an actor: to ensure sequential read/write operations
// and prevent race conditions when multiple Tasks make simultaneous calls
// (a user typing continuously, with each keystroke triggering a history write).

import CoreModels
import Foundation
import SwiftData

public actor SearchHistoryLocalStore {
    private let container: ModelContainer

    /// Limit the maximum number of stored history items — to prevent infinite data growth over time.
    private let maxItems: Int

    public init(maxItems: Int = 25) throws {
        self.maxItems = maxItems
        self.container = try ModelContainer(for: SearchHistoryEntity.self)
    }

    // MARK: - Fetch (newest first)

    public func fetchAll() throws -> [SearchHistoryItem] {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<SearchHistoryEntity>(
            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
        )
        descriptor.fetchLimit = maxItems
        let entities = try context.fetch(descriptor)
        return entities.map { SearchHistoryItem(id: $0.id, query: $0.query, searchedAt: $0.searchedAt) }
    }

    // MARK: - Add (if the query already exists, update the timestamp instead of creating a duplicate)

    public func add(query: String) throws {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SearchHistoryEntity>(
            predicate: #Predicate { $0.query == trimmed }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.searchedAt = Date()
        } else {
            let entity = SearchHistoryEntity(id: UUID().uuidString, query: trimmed, searchedAt: Date())
            context.insert(entity)
        }
        try context.save()
        try trimIfNeeded(context: context)
    }

    // MARK: - Remove 1 item

    public func remove(id: String) throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SearchHistoryEntity>(predicate: #Predicate { $0.id == id })
        if let entity = try context.fetch(descriptor).first {
            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Clear all

    public func clearAll() throws {
        let context = ModelContext(container)
        try context.delete(model: SearchHistoryEntity.self)
        try context.save()
    }

    // MARK: - Keep the number of items within the maxItems limit (remove the oldest item if exceeded).

    private func trimIfNeeded(context: ModelContext) throws {
        var descriptor = FetchDescriptor<SearchHistoryEntity>(
            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
        )
        let all = try context.fetch(descriptor)
        guard all.count > maxItems else { return }
        for entity in all[maxItems...] {
            context.delete(entity)
        }
        try context.save()
    }
}
