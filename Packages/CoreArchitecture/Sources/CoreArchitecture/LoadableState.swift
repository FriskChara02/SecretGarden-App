//
//  LoadableState.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Standard state for screens that "fetch a block of content and display it"
// (e.g., Detail screens, Profile screens). Do NOT use for paginated list screens.

import Foundation

public enum LoadableState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case failed(AppError)

    /// Available data, if the state is `.loaded`. Convenient for the View to use `if let`.
    public var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }

    /// `true` if currently loading — convenient for the View to show a `ProgressView()`.
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    /// Available error, if the state is `.failed`. Convenient for the View to show an Alert or Empty State.
    public var error: AppError? {
        if case .failed(let error) = self {
            return error
        }
        return nil
    }
}
