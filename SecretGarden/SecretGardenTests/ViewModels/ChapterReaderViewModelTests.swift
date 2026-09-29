//
//  ChapterReaderViewModelTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import CoreArchitecture
import CoreModels
import HomeFeature
import XCTest

@MainActor
final class ChapterReaderViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        series: Series = TestFixtures.series(),
        chapterCount: Int = 3,
        initialChapterId: String = "c2",
        pagesDelay: TimeInterval = 0,
        mutationDelay: TimeInterval = 0,
        mutationFailure: Error? = nil
    ) async -> (sut: ChapterReaderViewModel, repository: FakeSeriesRepository) {
        let repository = FakeSeriesRepository(
            detail: .success(series),
            chapters: .success(TestFixtures.chapters(count: chapterCount, seriesId: series.id)),
            pagesDelay: pagesDelay,
            mutationFailure: mutationFailure,
            mutationDelay: mutationDelay
        )
        let sut = ChapterReaderViewModel(
            seriesId: series.id,
            initialChapterId: initialChapterId,
            seriesRepository: repository,
            commentRepository: FakeCommentRepository()
        )
        sut.onAppear()
        await waitUntil { sut.seriesState.value != nil }
        return (sut, repository)
    }

    // MARK: - Loading

    func test_onAppear_selectsInitialChapterAndAppliesFavoriteNotifyStatus() async {
        let series = TestFixtures.series(isFavoritedByMe: true, isNotifyEnabled: true, readingStatus: .reading)
        let (sut, _) = await makeSUT(series: series, chapterCount: 3, initialChapterId: "c2")

        XCTAssertEqual(sut.currentChapter.id, "c2")
        XCTAssertTrue(sut.isFavoritedByMe)
        XCTAssertTrue(sut.isNotifyEnabled)
        XCTAssertEqual(sut.readingStatus, .reading)
        await waitUntil { sut.pagesState.value != nil }
    }

    func test_onAppear_whenInitialChapterIdNotFound_fallsBackToLastChapter() async {
        let (sut, _) = await makeSUT(chapterCount: 3, initialChapterId: "does-not-exist")

        XCTAssertEqual(sut.currentChapter.id, "c3", "c3 là chương mới nhất trong 3 chương")
    }

    func test_onAppear_loadsPagesCommentsAndGroupOtherSeries() async {
        let (sut, _) = await makeSUT()

        await waitUntil {
            sut.pagesState.value != nil && sut.commentsState.value != nil && sut.groupOtherSeriesState.value != nil
        }
    }

    // MARK: - Chapter navigation

    func test_chapterPickerItems_areOrderedNewestFirst() async {
        let (sut, _) = await makeSUT(chapterCount: 3, initialChapterId: "c1")

        XCTAssertEqual(sut.chapterPickerItems.map(\.id), ["c3", "c2", "c1"])
    }

    func test_navigationFlags_reflectPositionInSortedChapters() async {
        let first = await makeSUT(chapterCount: 3, initialChapterId: "c1").sut
        XCTAssertFalse(first.hasPreviousChapter)
        XCTAssertTrue(first.hasNextChapter)

        let last = await makeSUT(chapterCount: 3, initialChapterId: "c3").sut
        XCTAssertTrue(last.hasPreviousChapter)
        XCTAssertFalse(last.hasNextChapter)
    }

    func test_goToNextChapter_advancesAndResetsPagesAndComments() async {
        let (sut, _) = await makeSUT(chapterCount: 3, initialChapterId: "c1")
        await waitUntil { sut.pagesState.value != nil }

        sut.goToNextChapter()

        XCTAssertEqual(sut.currentChapter.id, "c2")
        XCTAssertEqual(sut.pagesState, .loading, "Đổi chương phải tải lại trang, không giữ trang cũ")
        await waitUntil { sut.pagesState.value != nil }
    }

    func test_goToPreviousChapter_atFirstChapter_doesNothing() async {
        let (sut, _) = await makeSUT(chapterCount: 3, initialChapterId: "c1")

        sut.goToPreviousChapter()

        XCTAssertEqual(sut.currentChapter.id, "c1")
    }

    func test_selectChapter_switchesAndClosesPicker() async {
        let (sut, _) = await makeSUT(chapterCount: 3, initialChapterId: "c1")
        sut.isChapterPickerPresented = true
        let target = sut.chapterPickerItems.first { $0.id == "c3" }!

        sut.selectChapter(target)

        XCTAssertEqual(sut.currentChapter.id, "c3")
        XCTAssertFalse(sut.isChapterPickerPresented)
    }

    func test_selectChapter_sameChapter_doesNotResetPagesState() async {
        let (sut, _) = await makeSUT(chapterCount: 3, initialChapterId: "c1")
        await waitUntil { sut.pagesState.value != nil }
        let loadedPagesState = sut.pagesState

        sut.selectChapter(sut.currentChapter)

        XCTAssertEqual(sut.pagesState, loadedPagesState, "Chọn lại đúng chương hiện tại không được tải lại")
    }

    // MARK: - Favorite / Notify / Reading status (mỗi field rollback riêng — không dính lỗi Step 15.6b)

    func test_toggleFavorite_success_updatesImmediatelyThenClearsFlag() async {
        let (sut, repository) = await makeSUT(series: TestFixtures.series(isFavoritedByMe: false))

        sut.toggleFavorite()

        XCTAssertTrue(sut.isFavoritedByMe)
        await waitUntil { !sut.isTogglingFavorite }
        let calls = await repository.favoriteCalls
        XCTAssertEqual(calls, [FakeSeriesRepository.FavoriteCall(seriesId: "s1", isFavorited: true)])
    }

    func test_toggleFavorite_failure_rollsBackOnlyFavoriteFlag() async {
        let error = AppError.network(.timeout)
        let (sut, _) = await makeSUT(
            series: TestFixtures.series(isFavoritedByMe: false, isNotifyEnabled: false),
            mutationFailure: error
        )

        sut.toggleFavorite()
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertFalse(sut.isFavoritedByMe)
        XCTAssertEqual(sut.actionErrorMessage, error.errorDescription)
    }

    func test_updateReadingStatus_success_updatesImmediately() async {
        let (sut, repository) = await makeSUT(series: TestFixtures.series(readingStatus: nil))

        sut.updateReadingStatus(to: .completed)

        XCTAssertEqual(sut.readingStatus, .completed)
        await waitUntil { !sut.isUpdatingReadingStatus }
        let calls = await repository.readingStatusCalls
        XCTAssertEqual(calls.first?.status, .completed)
    }

    func test_dismissActionError_clearsMessage() async {
        let (sut, _) = await makeSUT(mutationFailure: AppError.notFound)
        sut.toggleNotify()
        await waitUntil { sut.actionErrorMessage != nil }

        sut.dismissActionError()

        XCTAssertNil(sut.actionErrorMessage)
    }

    // MARK: - progressTask: When changing chapters, do not delete the final progress record of the previous chapter.

    func test_switchingChapterQuickly_stillRecordsFinalProgressOfPreviousChapter() async {
        // fetchChapterPages is nearly instantaneous -> loadPages() for the new chapter will run BEFORE
        // the 500ms debounce for recordProgress(old chapter) fires.
        let (sut, repository) = await makeSUT(chapterCount: 3, initialChapterId: "c1", pagesDelay: 0.01)
        await waitUntil { sut.pagesState.value != nil }

        sut.recordProgress(page: 10) // The reader is on page 10 of Chapter 1
        sut.goToNextChapter()        // click "next chapter" right before the 500ms debounce fires

        try? await Task.sleep(nanoseconds: 700_000_000) // debounce longer than 500ms
        let calls = await repository.progressCalls

        XCTAssertTrue(
            calls.contains(FakeSeriesRepository.ProgressCall(seriesId: "s1", chapterId: "c1", page: 10)),
            "Lần đọc cuối (trang 10) của chương c1 phải được ghi lại trước khi rời sang chương khác"
        )
    }

    // MARK: - Comment CRUD (chapter-level — same logic as SeriesDetailViewModel)

    func test_postComment_success_prependsNewCommentAndClearsDraft() async {
        let newComment = TestFixtures.comment(id: "new1", content: "Bình luận chương")
        let commentRepo = FakeCommentRepository(chapterComments: .success([]), postResult: .success(newComment))
        let repository = FakeSeriesRepository(chapters: .success(TestFixtures.chapters(count: 1, seriesId: "s1")))
        let sut = ChapterReaderViewModel(
            seriesId: "s1", initialChapterId: "c1", seriesRepository: repository, commentRepository: commentRepo
        )
        sut.onAppear()
        await waitUntil { sut.commentsState.value != nil }
        sut.commentDraft = "Bình luận chương"

        sut.postComment()

        await waitUntil { sut.commentsState.value?.count == 1 }
        XCTAssertEqual(sut.commentsState.value?.first?.id, "new1")
        XCTAssertEqual(sut.commentDraft, "")
        let calls = await commentRepo.postChapterCalls
        XCTAssertEqual(calls, ["Bình luận chương"])
    }

    func test_toggleCommentLike_failure_rollsBackToOriginalList() async {
        let error = AppError.unauthorized
        let original = [TestFixtures.comment(id: "cm1", likeCount: 2, isLikedByMe: false)]
        let commentRepo = FakeCommentRepository(chapterComments: .success(original), likeFailure: error)
        let repository = FakeSeriesRepository(chapters: .success(TestFixtures.chapters(count: 1, seriesId: "s1")))
        let sut = ChapterReaderViewModel(
            seriesId: "s1", initialChapterId: "c1", seriesRepository: repository, commentRepository: commentRepo
        )
        sut.onAppear()
        await waitUntil { sut.commentsState.value != nil }

        sut.toggleCommentLike(commentId: "cm1")
        await waitUntil { sut.actionErrorMessage != nil }

        XCTAssertEqual(sut.commentsState.value, original)
    }

    func test_submitReply_success_appendsToCorrectParent() async {
        let parent = TestFixtures.comment(id: "cm1", replies: nil)
        let newReply = TestFixtures.comment(id: "r-new", content: "Reply chương")
        let commentRepo = FakeCommentRepository(chapterComments: .success([parent]), replyResult: .success(newReply))
        let repository = FakeSeriesRepository(chapters: .success(TestFixtures.chapters(count: 1, seriesId: "s1")))
        let sut = ChapterReaderViewModel(
            seriesId: "s1", initialChapterId: "c1", seriesRepository: repository, commentRepository: commentRepo
        )
        sut.onAppear()
        await waitUntil { sut.commentsState.value != nil }
        sut.startReplying(to: "cm1")
        sut.replyDraft = "Reply chương"

        sut.submitReply()

        await waitUntil { sut.commentsState.value?.first?.replies?.count == 1 }
        XCTAssertEqual(sut.commentsState.value?.first?.replies?.first?.id, "r-new")
    }
}
