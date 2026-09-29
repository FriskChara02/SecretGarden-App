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

    // MARK: - Comment CRUD

    private func makeLoadedSUTWithComments(
        comments: [Comment],
        commentRepository: FakeCommentRepository? = nil
    ) async -> (sut: SeriesDetailViewModel, comments: FakeCommentRepository) {
        let commentRepo = commentRepository ?? FakeCommentRepository(seriesComments: .success(comments))
        let sut = SeriesDetailViewModel(
            seriesId: "s1",
            seriesRepository: FakeSeriesRepository(chapters: .success(TestFixtures.chapters(count: 1))),
            commentRepository: commentRepo
        )
        sut.onAppear()
        await waitUntil { sut.commentsState.value != nil }
        return (sut, commentRepo)
    }

    func test_postComment_success_prependsNewCommentAndClearsDraft() async {
        let newComment = TestFixtures.comment(id: "new1", content: "Bình luận mới")
        let repo = FakeCommentRepository(seriesComments: .success([TestFixtures.comment(id: "old1")]), postResult: .success(newComment))
        let (sut, commentRepo) = await makeLoadedSUTWithComments(comments: [], commentRepository: repo)
        sut.commentDraft = "Bình luận mới"

        sut.postComment()

        await waitUntil { sut.commentsState.value?.count == 2 }
        XCTAssertEqual(sut.commentsState.value?.first?.id, "new1", "Bình luận mới phải nằm đầu danh sách")
        XCTAssertEqual(sut.commentDraft, "")
        let calls = await commentRepo.postSeriesCalls
        XCTAssertEqual(calls, ["Bình luận mới"])
    }

    func test_postComment_blank_doesNotCallRepository() async {
        let (sut, commentRepo) = await makeLoadedSUTWithComments(comments: [])
        sut.commentDraft = "   "

        sut.postComment()

        let calls = await commentRepo.postSeriesCalls
        XCTAssertTrue(calls.isEmpty)
    }

    func test_toggleCommentLike_topLevel_updatesOptimisticallyAndLeavesOthersUnchanged() async {
        let target = TestFixtures.comment(id: "cm1", likeCount: 3, isLikedByMe: false)
        let other = TestFixtures.comment(id: "cm2", likeCount: 5, isLikedByMe: true)
        let (sut, commentRepo) = await makeLoadedSUTWithComments(comments: [target, other])

        sut.toggleCommentLike(commentId: "cm1")

        let liked = sut.commentsState.value?.first { $0.id == "cm1" }
        XCTAssertEqual(liked?.isLikedByMe, true)
        XCTAssertEqual(liked?.likeCount, 4)
        let untouched = sut.commentsState.value?.first { $0.id == "cm2" }
        XCTAssertEqual(untouched, other, "Comment không liên quan phải giữ nguyên")

        try? await Task.sleep(nanoseconds: 100_000_000)
        let calls = await commentRepo.likeCalls
        XCTAssertEqual(calls, [FakeCommentRepository.LikeCall(commentId: "cm1", isLiked: true)])
    }

    func test_toggleCommentLike_reply_updatesOnlyThatReply() async {
        let reply = TestFixtures.comment(id: "r1", likeCount: 0, isLikedByMe: false)
        let parent = TestFixtures.comment(id: "cm1", replies: [reply])
        let (sut, _) = await makeLoadedSUTWithComments(comments: [parent])

        sut.toggleCommentLike(commentId: "r1")

        let updatedReply = sut.commentsState.value?.first?.replies?.first
        XCTAssertEqual(updatedReply?.isLikedByMe, true)
        XCTAssertEqual(updatedReply?.likeCount, 1)
    }

    func test_toggleCommentLike_failure_rollsBackToOriginalList() async {
        let error = AppError.network(.timeout)
        let original = [TestFixtures.comment(id: "cm1", likeCount: 3, isLikedByMe: false)]
        let repo = FakeCommentRepository(seriesComments: .success(original), likeFailure: error)
        let (sut, _) = await makeLoadedSUTWithComments(comments: [], commentRepository: repo)

        sut.toggleCommentLike(commentId: "cm1")
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertEqual(sut.commentsState.value, original)
        XCTAssertEqual(sut.actionErrorMessage, error.errorDescription)
    }

    func test_submitReply_success_appendsToCorrectParentAndClearsComposer() async {
        let parent = TestFixtures.comment(id: "cm1", replies: nil)
        let newReply = TestFixtures.comment(id: "r-new", content: "Reply mới")
        let repo = FakeCommentRepository(seriesComments: .success([parent]), replyResult: .success(newReply))
        let (sut, commentRepo) = await makeLoadedSUTWithComments(comments: [], commentRepository: repo)
        sut.startReplying(to: "cm1")
        sut.replyDraft = "Reply mới"

        sut.submitReply()

        await waitUntil { sut.commentsState.value?.first?.replies?.count == 1 }
        XCTAssertEqual(sut.commentsState.value?.first?.replies?.first?.id, "r-new")
        XCTAssertNil(sut.replyingToCommentId)
        XCTAssertEqual(sut.replyDraft, "")
        let calls = await commentRepo.replyCalls
        XCTAssertEqual(calls, [FakeCommentRepository.ReplyCall(parentCommentId: "cm1", content: "Reply mới")])
    }

    func test_cancelReplying_clearsComposerWithoutCallingRepository() async {
        let (sut, commentRepo) = await makeLoadedSUTWithComments(comments: [TestFixtures.comment(id: "cm1")])
        sut.startReplying(to: "cm1")
        sut.replyDraft = "Chưa gửi"

        sut.cancelReplying()

        XCTAssertNil(sut.replyingToCommentId)
        XCTAssertEqual(sut.replyDraft, "")
        let calls = await commentRepo.replyCalls
        XCTAssertTrue(calls.isEmpty)
    }
}
