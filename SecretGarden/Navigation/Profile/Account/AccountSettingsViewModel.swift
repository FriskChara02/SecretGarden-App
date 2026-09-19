//
//  AccountSettingsViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreArchitecture
import CoreModels
import Foundation
import Repositories
import Combine

@MainActor
final class AccountSettingsViewModel: BaseViewModel {

    private let userRepository: UserRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol

    @Published private(set) var currentUser: User
    @Published var editingUsername: String
    @Published var editingDisplayName: String
    @Published var editingEmail: String

    @Published private(set) var fieldSubmissionState: FormSubmissionState = .idle
    @Published var passwordSubmissionState: FormSubmissionState = .idle

    init(currentUser: User, userRepository: UserRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.currentUser = currentUser
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.editingUsername = currentUser.username
        self.editingDisplayName = currentUser.displayName ?? ""
        self.editingEmail = currentUser.email
        super.init()
    }

    var canEditContactInfo: Bool {
        currentUser.authProvider == .email
    }

    func saveUsername(onSaved: @escaping (User) -> Void) {
        submitAccount(username: editingUsername, email: currentUser.email, onSaved: onSaved)
    }

    func saveEmail(onSaved: @escaping (User) -> Void) {
        submitAccount(username: currentUser.username, email: editingEmail, onSaved: onSaved)
    }

    func saveDisplayName(onSaved: @escaping (User) -> Void) {
        fieldSubmissionState = .submitting
        Task { [weak self] in
            guard let self else { return }
            do {
                let request = UpdateProfileRequest(displayName: self.editingDisplayName)
                let updated = try await self.userRepository.updateProfile(request)
                self.currentUser = updated
                self.fieldSubmissionState = .succeeded
                onSaved(updated)
            } catch {
                self.fieldSubmissionState = .failed(self.mapToAppError(error))
            }
        }
    }

    func changePassword(oldPassword: String, newPassword: String) {
        passwordSubmissionState = .submitting
        Task { [weak self] in
            guard let self else { return }
            do {
                let request = ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword)
                try await self.authRepository.changePassword(request)
                self.passwordSubmissionState = .succeeded
            } catch {
                self.passwordSubmissionState = .failed(self.mapToAppError(error))
            }
        }
    }

    // MARK: - Private

    private func submitAccount(username: String, email: String, onSaved: @escaping (User) -> Void) {
        fieldSubmissionState = .submitting
        Task { [weak self] in
            guard let self else { return }
            do {
                let request = UpdateAccountRequest(username: username, email: email)
                let updated = try await self.userRepository.updateAccount(request)
                self.currentUser = updated
                self.fieldSubmissionState = .succeeded
                onSaved(updated)
            } catch {
                self.fieldSubmissionState = .failed(self.mapToAppError(error))
            }
        }
    }
}
