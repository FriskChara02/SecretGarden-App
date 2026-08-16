//
//  FormSubmissionState.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 16/8/26.
//

// A shared state for ALL "submit form/action" operations (Login, Register,
// ForgotPassword, EditProfile, UploadRegistration...) — distinct from LoadableState<T>:
// There is NO .loaded(T) case carrying a payload, as these actions do not "display fetched content";
// the UI only needs to know the status (submitting / completed / error) — typically to navigate to the next screen
// or show an alert, rather than to render data into a list or detail view.

import Foundation

public enum FormSubmissionState: Equatable {
    case idle
    case submitting
    case succeeded
    case failed(AppError)

    /// `true` if currently submitting — useful for the View to disable the button / show a ProgressView.
    public var isSubmitting: Bool {
        if case .submitting = self {
            return true
        }
        return false
    }

    /// The current error, if the state is `.failed`.
    public var error: AppError? {
        if case .failed(let error) = self {
            return error
        }
        return nil
    }
}
