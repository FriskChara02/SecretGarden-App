//
//  BlockListRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import CoreNetworking

public final class BlockListRepository: BlockListRepositoryProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchBlockedSeries() async throws -> [BlockedSeriesItem] {
        try await apiClient.request(BlockListEndpoint.fetchBlockedSeries)
    }

    public func fetchBlockedTags() async throws -> [BlockedTagItem] {
        try await apiClient.request(BlockListEndpoint.fetchBlockedTags)
    }

    public func blockSeries(seriesId: String) async throws {
        try await apiClient.requestWithoutResponse(BlockListEndpoint.blockSeries(seriesId: seriesId))
    }

    public func unblockSeries(seriesId: String) async throws {
        try await apiClient.requestWithoutResponse(BlockListEndpoint.unblockSeries(seriesId: seriesId))
    }

    public func blockTag(tagId: String) async throws {
        try await apiClient.requestWithoutResponse(BlockListEndpoint.blockTag(tagId: tagId))
    }

    public func unblockTag(tagId: String) async throws {
        try await apiClient.requestWithoutResponse(BlockListEndpoint.unblockTag(tagId: tagId))
    }
}
