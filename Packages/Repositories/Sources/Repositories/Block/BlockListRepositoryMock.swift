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

    public func unblockSeries(seriesId: String) async throws {
        blockedSeries.removeAll { $0.series.id == seriesId }
    }

    public func blockTag(tagId: String) async throws {}

    public func unblockTag(tagId: String) async throws {
        blockedTags.removeAll { $0.tag.id == tagId }
    }
}
