//
//  SeriesDetailViewModelTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import CoreModels
import HomeFeature
import XCTest

@MainActor
final class SeriesDetailViewModelTests: XCTestCase {

    // MARK: - Helpers

    /// Set up the ViewModel, call onAppear and wait for the critical data (details + chapters) to finish loading.
    private func makeLoadedSUT(
        series: Series = TestFixtures.series(),
        chapterCount: Int = 3,
        mutationFailure: Error? = nil,
        mutationDelay: TimeInterval = 0,
        behaviors: [FakeSeriesRepository.Mutation: FakeSeriesRepository.Behavior] = [:]
    ) async -> (sut: SeriesDetailViewModel, repository: FakeSeriesRepository) {
        let repository = FakeSeriesRepository(
            detail: .success(series),
            chapters: .success(TestFixtures.chapters(count: chapterCount, seriesId: series.id)),
            mutationFailure: mutationFailure,
            mutationDelay: mutationDelay,
            behaviors: behaviors
        )
        let sut = SeriesDetailViewModel(
            seriesId: series.id,
            seriesRepository: repository,
            commentRepository: FakeCommentRepository()
        )
        sut.onAppear()
        await waitUntil { sut.detailState.value != nil && sut.chaptersState.value != nil }
        return (sut, repository)
    }

    /// Actual scenario: "Like" operation proceeds slowly and fails, while the "Notification" operation succeeds.
    /// The rollback of the "Like" operation must not undo the (successful) changes made by the "Notification" operation.
    func test_toggleFavorite_failingAfterNotifySucceeds_keepsNotifyChange() async {
        let error = AppError.network(.timeout)
        let original = TestFixtures.series(favoriteCount: 10, isFavoritedByMe: false, isNotifyEnabled: false)
        let (sut, _) = await makeLoadedSUT(
            series: original,
            behaviors: [.favorite: .init(delay: 0.2, failure: error)] // Default notification: immediate success
        )

        sut.toggleFavorite() // delays 0.2s, then errors out
        sut.toggleNotify()   // immediate success, inserted in between

        await waitUntil { sut.actionErrorMessage != nil } // Favorites failed and rolled back

        XCTAssertEqual(sut.detailState.value?.isFavoritedByMe, false, "Yêu thích phải được hoàn lại")
        XCTAssertEqual(sut.detailState.value?.favoriteCount, 10)
        XCTAssertEqual(sut.detailState.value?.isNotifyEnabled, true, "Thông báo đã thành công, không được bị hoàn lại theo")
        await waitUntil { !sut.isTogglingFavorite && !sut.isTogglingNotify }
    }

    // MARK: - Loading

    func test_onAppear_startsLoadingAllSectionsThenLoadsThem() async {
        let repository = FakeSeriesRepository(chapters: .success(TestFixtures.chapters(count: 2)))
        let sut = SeriesDetailViewModel(
            seriesId: "s1",
            seriesRepository: repository,
            commentRepository: FakeCommentRepository()
        )

        sut.onAppear()

        XCTAssertEqual(sut.detailState, .loading)
        XCTAssertEqual(sut.chaptersState, .loading)
        XCTAssertEqual(sut.relatedState, .loading)
        XCTAssertEqual(sut.commentsState, .loading)

        await waitUntil {
            sut.detailState.value != nil
                && sut.chaptersState.value?.count == 2
                && sut.relatedState.value != nil
                && sut.commentsState.value != nil
        }
        XCTAssertEqual(sut.detailState.value?.id, "s1")
    }

    func test_onAppear_whenDetailFails_bothCriticalStatesFailTogether() async {
        let repository = FakeSeriesRepository(
            detail: .failure(AppError.notFound),
            chapters: .success(TestFixtures.chapters(count: 2))
        )
        let sut = SeriesDetailViewModel(
            seriesId: "s1",
            seriesRepository: repository,
            commentRepository: FakeCommentRepository()
        )

        sut.onAppear()

        await waitUntil { sut.detailState == .failed(.notFound) }
        XCTAssertEqual(sut.chaptersState, .failed(.notFound), "Detail + chapters là critical: fail cùng nhau")
    }

    func test_onAppear_whenSecondarySectionsFail_criticalContentStillLoads() async {
        let repository = FakeSeriesRepository(related: .failure(AppError.network(.timeout)))
        let comments = FakeCommentRepository(seriesComments: .failure(AppError.unauthorized))
        let sut = SeriesDetailViewModel(seriesId: "s1", seriesRepository: repository, commentRepository: comments)

        sut.onAppear()

        await waitUntil {
            sut.detailState.value != nil && sut.relatedState.error != nil && sut.commentsState.error != nil
        }
        XCTAssertEqual(sut.relatedState, .failed(.network(.timeout)))
        XCTAssertEqual(sut.commentsState, .failed(.unauthorized))
        XCTAssertNotNil(sut.chaptersState.value)
    }

    // MARK: - Chapter list (client-side)

    func test_visibleSortedChapters_defaultsToNewestFirstLimitedToFive() async {
        let (sut, _) = await makeLoadedSUT(chapterCount: 8)

        XCTAssertEqual(sut.visibleSortedChapters.map(\.chapterNumber), [8, 7, 6, 5, 4])
        XCTAssertTrue(sut.hasMoreChapters)
    }

    func test_setChaptersSortDescending_false_showsOldestFirst() async {
        let (sut, _) = await makeLoadedSUT(chapterCount: 8)

        sut.setChaptersSortDescending(false)

        XCTAssertEqual(sut.visibleSortedChapters.map(\.chapterNumber), [1, 2, 3, 4, 5])
    }

    func test_toggleChaptersSortOrder_flipsOrder() async {
        let (sut, _) = await makeLoadedSUT(chapterCount: 8)
        XCTAssertTrue(sut.chaptersSortDescending)

        sut.toggleChaptersSortOrder()

        XCTAssertFalse(sut.chaptersSortDescending)
        XCTAssertEqual(sut.visibleSortedChapters.first?.chapterNumber, 1)
    }

    func test_showMoreChapters_revealsAllAndHidesMoreButton() async {
        let (sut, _) = await makeLoadedSUT(chapterCount: 8)

        sut.showMoreChapters()

        XCTAssertEqual(sut.visibleSortedChapters.count, 8)
        XCTAssertFalse(sut.hasMoreChapters)
    }

    // MARK: - Favorite (optimistic)

    func test_toggleFavorite_success_updatesImmediatelyAndCallsRepository() async {
        let (sut, repository) = await makeLoadedSUT(
            series: TestFixtures.series(favoriteCount: 10, isFavoritedByMe: false)
        )

        sut.toggleFavorite()

        // The optimistic state appears IMMEDIATELY, before the Repository responds.
        XCTAssertEqual(sut.detailState.value?.isFavoritedByMe, true)
        XCTAssertEqual(sut.detailState.value?.favoriteCount, 11)
        XCTAssertTrue(sut.isTogglingFavorite)

        await waitUntil { !sut.isTogglingFavorite }
        let calls = await repository.favoriteCalls
        XCTAssertEqual(calls, [FakeSeriesRepository.FavoriteCall(seriesId: "s1", isFavorited: true)])
        XCTAssertNil(sut.actionErrorMessage)
        XCTAssertEqual(sut.detailState.value?.isFavoritedByMe, true)
    }

    func test_toggleFavorite_whenAlreadyFavorited_unfavoritesAndDecrementsCount() async {
        let (sut, repository) = await makeLoadedSUT(
            series: TestFixtures.series(favoriteCount: 10, isFavoritedByMe: true)
        )

        sut.toggleFavorite()

        XCTAssertEqual(sut.detailState.value?.isFavoritedByMe, false)
        XCTAssertEqual(sut.detailState.value?.favoriteCount, 9)
        await waitUntil { !sut.isTogglingFavorite }
        let calls = await repository.favoriteCalls
        XCTAssertEqual(calls, [FakeSeriesRepository.FavoriteCall(seriesId: "s1", isFavorited: false)])
    }

    func test_toggleFavorite_failure_rollsBackToOriginalAndShowsError() async {
        let error = AppError.network(.noInternetConnection)
        let original = TestFixtures.series(favoriteCount: 10, isFavoritedByMe: false)
        let (sut, _) = await makeLoadedSUT(series: original, mutationFailure: error)

        sut.toggleFavorite()
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertEqual(sut.actionErrorMessage, error.errorDescription)
        XCTAssertEqual(sut.detailState.value, original, "Rollback phải trả đúng trạng thái ban đầu")
        await waitUntil { !sut.isTogglingFavorite }
    }

    func test_toggleFavorite_whileInFlight_ignoresSecondTap() async {
        let (sut, repository) = await makeLoadedSUT(mutationDelay: 0.2)

        sut.toggleFavorite()
        sut.toggleFavorite() // press a second time while the first attempt is still in progress

        await waitUntil { !sut.isTogglingFavorite }
        let calls = await repository.favoriteCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(sut.detailState.value?.isFavoritedByMe, true, "Không được lật ngược về false")
    }

    // MARK: - Notify (optimistic)

    func test_toggleNotify_success_updatesImmediatelyAndCallsRepository() async {
        let (sut, repository) = await makeLoadedSUT(series: TestFixtures.series(isNotifyEnabled: false))

        sut.toggleNotify()

        XCTAssertEqual(sut.detailState.value?.isNotifyEnabled, true)
        XCTAssertTrue(sut.isTogglingNotify)
        await waitUntil { !sut.isTogglingNotify }
        let calls = await repository.notifyCalls
        XCTAssertEqual(calls, [FakeSeriesRepository.NotifyCall(seriesId: "s1", enabled: true)])
    }

    func test_toggleNotify_failure_rollsBackAndShowsError() async {
        let error = AppError.network(.timeout)
        let original = TestFixtures.series(isNotifyEnabled: false)
        let (sut, _) = await makeLoadedSUT(series: original, mutationFailure: error)

        sut.toggleNotify()
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertEqual(sut.actionErrorMessage, error.errorDescription)
        XCTAssertEqual(sut.detailState.value, original)
        await waitUntil { !sut.isTogglingNotify }
    }

    // MARK: - Reading status (optimistic)

    func test_updateReadingStatus_success_updatesImmediatelyAndForwardsNotifyFlag() async {
        let (sut, repository) = await makeLoadedSUT(
            series: TestFixtures.series(isNotifyEnabled: true, readingStatus: nil)
        )

        sut.updateReadingStatus(to: .reading)

        XCTAssertEqual(sut.detailState.value?.readingStatus, .reading)
        XCTAssertTrue(sut.isUpdatingReadingStatus)
        await waitUntil { !sut.isUpdatingReadingStatus }
        let calls = await repository.readingStatusCalls
        XCTAssertEqual(
            calls,
            [FakeSeriesRepository.ReadingStatusCall(seriesId: "s1", status: .reading, notifyNewChapter: true)]
        )
    }

    func test_updateReadingStatus_failure_rollsBackAndShowsError() async {
        let error = AppError.unauthorized
        let original = TestFixtures.series(readingStatus: nil)
        let (sut, _) = await makeLoadedSUT(series: original, mutationFailure: error)

        sut.updateReadingStatus(to: .completed)
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertEqual(sut.actionErrorMessage, error.errorDescription)
        XCTAssertEqual(sut.detailState.value, original)
        await waitUntil { !sut.isUpdatingReadingStatus }
    }

    // MARK: - Remove from list (optimistic)

    func test_removeFromReadingList_success_clearsStatusAndCallsRepository() async {
        let (sut, repository) = await makeLoadedSUT(series: TestFixtures.series(readingStatus: .completed))

        sut.removeFromReadingList()

        XCTAssertNil(sut.detailState.value?.readingStatus)
        await waitUntil { !sut.isUpdatingReadingStatus }
        let calls = await repository.removeStatusCalls
        XCTAssertEqual(calls, ["s1"])
    }

    func test_removeFromReadingList_failure_restoresPreviousStatus() async {
        let error = AppError.network(.noInternetConnection)
        let original = TestFixtures.series(readingStatus: .completed)
        let (sut, _) = await makeLoadedSUT(series: original, mutationFailure: error)

        sut.removeFromReadingList()
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertEqual(sut.detailState.value?.readingStatus, .completed)
        XCTAssertEqual(sut.detailState.value, original)
        await waitUntil { !sut.isUpdatingReadingStatus }
    }

    // MARK: - Guard: Actions do nothing until loading is complete

    func test_actions_beforeDetailLoaded_doNothing() async {
        let repository = FakeSeriesRepository()
        let sut = SeriesDetailViewModel(
            seriesId: "s1",
            seriesRepository: repository,
            commentRepository: FakeCommentRepository()
        )

        sut.toggleFavorite()
        sut.toggleNotify()
        sut.updateReadingStatus(to: .reading)
        sut.removeFromReadingList()

        XCTAssertFalse(sut.isTogglingFavorite)
        XCTAssertFalse(sut.isTogglingNotify)
        XCTAssertFalse(sut.isUpdatingReadingStatus)
        let favorites = await repository.favoriteCalls
        let notifies = await repository.notifyCalls
        let statuses = await repository.readingStatusCalls
        let removals = await repository.removeStatusCalls
        XCTAssertTrue(favorites.isEmpty && notifies.isEmpty && statuses.isEmpty && removals.isEmpty)
    }
}
