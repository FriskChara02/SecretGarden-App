//
//  BaseViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Base class for ALL ViewModels in the project — handles shared Task lifecycle logic:
// automatically cancels the old Task when a new one starts (preventing race conditions)
// and maps unexpected errors to AppError (a final safeguard in case a Repository
// fails to map an error).
//
// This class does NOT manage specific @Published state properties (like isLoading or error)
// because different screens require different states (e.g., a content-heavy screen might use
// a LoadableViewModel, whereas an action-oriented screen like a Login view needs a different
// state setup). BaseViewModel focuses solely on the SHARED aspect: executing Tasks safely.

import Combine
import Foundation

@MainActor
open class BaseViewModel: ObservableObject {
    private var currentTask: Task<Void, Never>?

    public init() {}

    /// Executes an async throwing operation, automatically cancelling any previously running task.
    /// - Parameters:
    ///   - operation: The async task to execute (typically a Repository call).
    ///   - onError: A callback receiving a pre-mapped `AppError`; the child ViewModel
    ///     determines which state to update when an error occurs.
    public func runTask(
        _ operation: @escaping () async throws -> Void,
        onError: @escaping (AppError) -> Void = { _ in }
    ) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await operation()
            } catch is CancellationError {
                // Intentionally cancelled task (e.g., user refreshes a second time) — NOT considered an error;
                // do not call onError to avoid showing a misleading error alert to the user.
            } catch {
                onError(self.mapToAppError(error))
            }
        }
    }

    /// Maps any `Error` to `AppError`. Marked `nonisolated` because this function
    /// does not access any `@Published` properties—allowing it to be called from outside the MainActor
    /// (useful for writing unit tests without needing `await` or `@MainActor` specifically for this function).
    nonisolated public func mapToAppError(_ error: Error) -> AppError {
        (error as? AppError) ?? .unknown(String(describing: error))
    }

    deinit {
        currentTask?.cancel()
    }
}
