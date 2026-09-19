//
//  BlockListRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels

public protocol BlockListRepositoryProtocol: Sendable {
    func fetchBlockedSeries() async throws -> [BlockedSeriesItem]
    func fetchBlockedTags() async throws -> [BlockedTagItem]

    func blockSeries(seriesId: String) async throws
    func unblockSeries(seriesId: String) async throws

    func blockTag(tagId: String) async throws
    func unblockTag(tagId: String) async throws
}
