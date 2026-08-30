//
//  SearchRemoteDataSource.swift
//  Repositories
//
//  Created by Loi Nguyen on 29/8/26.
//

// Separate the "search API call" logic from SearchRepository so that the Container (App target)
// can choose between Mock and Real implementations without SearchRepository having a reverse dependency on AppConfig.

import CoreModels
import CoreNetworking
import Foundation

public protocol SearchRemoteDataSource: Sendable {
    func searchBasic(query: String, page: Int) async throws -> [Series]
    func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series]
    func fetchFilterOptions() async throws -> AdvancedFilterOptions
}

// MARK: - Production version, calling APIClient

public final class SearchRemoteAPIDataSource: SearchRemoteDataSource {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func searchBasic(query: String, page: Int) async throws -> [Series] {
        try await apiClient.request(SearchEndpoint.basicSearch(query: query, page: page))
    }

    public func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series] {
        try await apiClient.request(SearchEndpoint.advancedSearch(filter: filter, page: page))
    }

    // TODO(server): The backend needs to add endpoints such as GET /tags and GET /pairings,
    // as well as endpoints for abbreviated lists of Authors, Artists and Translation Groups.
    public func fetchFilterOptions() async throws -> AdvancedFilterOptions {
        AdvancedFilterOptions()
    }
}

// MARK: - Mock version, used for debugging (to avoid DNS errors since the actual backend does not yet exist).

public final class SearchRemoteMockDataSource: SearchRemoteDataSource {

    public init() {}

    // swiftlint:disable force_unwrapping
    // Reason for disabling: The URL below is a hardcoded literal for mock data, not dynamic input
    // from the network/user—there is no risk of an actual crash.
    private static let coverURL1 = URL(string: "https://picsum.photos/seed/search1/400/560")!
    private static let coverURL2 = URL(string: "https://picsum.photos/seed/search2/400/560")!
    private static let coverURL3 = URL(string: "https://picsum.photos/seed/search3/400/560")!
    private static let coverURL4 = URL(string: "https://picsum.photos/seed/search4/400/560")!
    // swiftlint:enable force_unwrapping

    // MARK: - Sample data for basic search.

    private static let samplePool: [Series] = [
        Series(
            id: "search_mock_1",
            title: "Ánh Trăng Bên Em",
            type: .manga,
            coverURL: coverURL1,
            description: "Dữ liệu mẫu cho luồng tìm kiếm — dùng để test trên Simulator trước khi có backend thật.",
            status: .ongoing,
            author: AuthorGroupCommon(id: "author_search_1", name: "Chise, Ciweimao"),
            group: TranslationGroup(id: "group_search_1", name: "Knights of Yuri"),
            genres: [Genre(id: "genre_1", name: "Yuri"), Genre(id: "genre_2", name: "Slice of Life")],
            viewCount: 5200, favoriteCount: 980,
            updatedAt: Date(timeIntervalSinceNow: -3600),
            latestChapterLabel: "Chương 12"
        ),
        Series(
            id: "search_mock_2",
            title: "Đồng Điệu Trái Tim",
            type: .manga,
            coverURL: coverURL2,
            description: "Dữ liệu mẫu cho luồng tìm kiếm — dùng để test trên Simulator trước khi có backend thật.",
            status: .completed,
            author: AuthorGroupCommon(id: "author_search_2", name: "Kanno Fumi"),
            group: TranslationGroup(id: "group_search_2", name: "Yune Projekt"),
            genres: [Genre(id: "genre_3", name: "Comedy"), Genre(id: "genre_4", name: "School Life")],
            viewCount: 3100, favoriteCount: 720,
            updatedAt: Date(timeIntervalSinceNow: -7200),
            latestChapterLabel: "Chương Oneshot"
        ),
        Series(
            id: "search_mock_3",
            title: "Hoa Anh Đào Mùa Hạ",
            type: .manga,
            coverURL: coverURL3,
            description: "Dữ liệu mẫu cho luồng tìm kiếm — dùng để test trên Simulator trước khi có backend thật.",
            status: .ongoing,
            author: AuthorGroupCommon(id: "author_search_3", name: "Radish"),
            group: TranslationGroup(id: "group_search_1", name: "Knights of Yuri"),
            genres: [Genre(id: "genre_1", name: "Yuri"), Genre(id: "genre_5", name: "Drama")],
            viewCount: 8400, favoriteCount: 1500,
            updatedAt: Date(timeIntervalSinceNow: -1800),
            latestChapterLabel: "Chương 5"
        ),
        Series(
            id: "search_mock_4",
            title: "Lời Hứa Dưới Giàn Hoa Tím",
            type: .manga,
            coverURL: coverURL4,
            description: "Dữ liệu mẫu cho luồng tìm kiếm — dùng để test trên Simulator trước khi có backend thật.",
            status: .completed,
            author: AuthorGroupCommon(id: "author_search_1", name: "Chise, Ciweimao"),
            group: TranslationGroup(id: "group_search_1", name: "Knights of Yuri"),
            genres: [Genre(id: "genre_6", name: "Fantasy")],
            viewCount: 2600, favoriteCount: 410,
            updatedAt: Date(timeIntervalSinceNow: -10800),
            latestChapterLabel: "Chương 21"
        )
    ]

    // MARK: - Sample data for Advanced Filter.
    
    private static let sampleOptions = AdvancedFilterOptions(
        tags: [
            Tag(id: "tag_1", name: "Espionage"), Tag(id: "tag_2", name: "4-koma"),
            Tag(id: "tag_3", name: "Abuse"), Tag(id: "tag_4", name: "Action"),
            Tag(id: "tag_5", name: "Adult Life"), Tag(id: "tag_6", name: "Adventure"),
            Tag(id: "tag_7", name: "Age Gap"), Tag(id: "tag_8", name: "Animal Ears"),
            Tag(id: "tag_9", name: "Comedy"), Tag(id: "tag_10", name: "Drama"),
            Tag(id: "tag_11", name: "Fantasy"), Tag(id: "tag_12", name: "Full Color"),
            Tag(id: "tag_13", name: "School Life"), Tag(id: "tag_14", name: "Slice of Life")
        ],
        authors: [
            AuthorGroupCommon(id: "author_search_1", name: "Chise, Ciweimao"),
            AuthorGroupCommon(id: "author_search_2", name: "Kanno Fumi"),
            AuthorGroupCommon(id: "author_search_3", name: "Radish")
        ],
        artists: [
            AuthorGroupCommon(id: "artist_1", name: "Luoman"),
            AuthorGroupCommon(id: "artist_2", name: "Takeshima Eku")
        ],
        pairings: [
            Pairing(id: "pairing_1", name: "Tomboy x Femme"),
            Pairing(id: "pairing_2", name: "Childhood Friends"),
            Pairing(id: "pairing_3", name: "Senpai x Kouhai")
        ],
        groups: [
            TranslationGroup(id: "group_search_1", name: "Knights of Yuri"),
            TranslationGroup(id: "group_search_2", name: "Yune Projekt")
        ]
    )

    public func fetchFilterOptions() async throws -> AdvancedFilterOptions {
        try await Task.sleep(nanoseconds: 300_000_000)
        return Self.sampleOptions
    }

    public func searchBasic(query: String, page: Int) async throws -> [Series] {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard page == 1 else { return [] }
        return Self.samplePool.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    public func searchAdvanced(filter: AdvancedFilterRequest, page: Int) async throws -> [Series] {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard page == 1 else { return [] }
        // TODO: Apply the actual filter.includeTags/status/minChapterCount... to samplePool
        // once AdvancedFilterView is wired up — currently returning the raw pool to set.
        return Self.samplePool
    }
}
