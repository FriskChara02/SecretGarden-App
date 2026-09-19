//
//  BlockListRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import Foundation

public actor BlockListRepositoryMock: BlockListRepositoryProtocol {

    private var blockedSeries: [BlockedSeriesItem] = []
    private var blockedTags: [BlockedTagItem] = []

    public init() {}

    public func fetchBlockedSeries() async throws -> [BlockedSeriesItem] {
        blockedSeries
    }

    public func fetchBlockedTags() async throws -> [BlockedTagItem] {
        blockedTags
    }

    public func blockSeries(seriesId: String) async throws {}

    /// Overload specifically for Mock/Preview – accepts the Series directly to avoid re-fetching.
    public func blockSeries(_ series: Series) async throws {
        guard !blockedSeries.contains(where: { $0.series.id == series.id }) else { return }
        blockedSeries.append(BlockedSeriesItem(id: UUID().uuidString, series: series, blockedAt: Date()))
    }

    public func unblockSeries(seriesId: String) async throws {
        blockedSeries.removeAll { $0.series.id == seriesId }
    }

    public func blockTag(tagId: String) async throws {}

    /// Overload intended solely for Mock/Preview.
    public func blockTag(_ tag: Tag) async throws {
        guard !blockedTags.contains(where: { $0.tag.id == tag.id }) else { return }
        blockedTags.append(BlockedTagItem(id: UUID().uuidString, tag: tag, blockedAt: Date()))
    }

    public func unblockTag(tagId: String) async throws {
        blockedTags.removeAll { $0.tag.id == tagId }
    }
}
