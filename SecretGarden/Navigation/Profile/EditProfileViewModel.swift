//
//  EditProfileViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreArchitecture
import CoreModels
import Foundation
import Repositories
import Combine
import SwiftUI

@MainActor
final class EditProfileViewModel: BaseViewModel {

    private let currentUser: User
    private let userRepository: UserRepositoryProtocol

    @Published var bio: String
    @Published var interests: String
    @Published var address: String
    @Published var gender: String
    @Published var birthDay: Int
    @Published var birthMonth: Int
    @Published var birthYear: Int
    @Published var facebookLink: String
    @Published var discordLink: String

    @Published private(set) var submissionState: FormSubmissionState = .idle
    @Published private(set) var updatedUser: User?

    let yearRange: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 100)...currentYear).reversed()
    }()

    init(currentUser: User, userRepository: UserRepositoryProtocol) {
        self.currentUser = currentUser
        self.userRepository = userRepository

        self.bio = currentUser.bio ?? ""
        self.interests = currentUser.interests ?? ""
        self.address = currentUser.address ?? ""
        self.gender = currentUser.gender ?? "Nam"

        let calendar = Calendar.current
        let birthday = currentUser.birthday ?? Date()
        self.birthDay = calendar.component(.day, from: birthday)
        self.birthMonth = calendar.component(.month, from: birthday)
        self.birthYear = calendar.component(.year, from: birthday)

        self.facebookLink = currentUser.socialLinks?["facebook"] ?? ""
        self.discordLink = currentUser.socialLinks?["discord"] ?? ""

        super.init()
    }

    var canSubmit: Bool {
        !submissionState.isSubmitting
    }

    func save() {
        guard canSubmit else { return }
        submissionState = .submitting

        var socialLinks: [String: String] = [:]
        if !facebookLink.trimmingCharacters(in: .whitespaces).isEmpty {
            socialLinks["facebook"] = facebookLink
        }
        if !discordLink.trimmingCharacters(in: .whitespaces).isEmpty {
            socialLinks["discord"] = discordLink
        }

        let request = UpdateProfileRequest(
            displayName: nil,
            bio: bio,
            birthday: composedBirthday,
            gender: gender,
            address: address,
            interests: interests,
            socialLinks: socialLinks
        )

        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await self.userRepository.updateProfile(request)
                self.updatedUser = user
                self.submissionState = .succeeded
            } catch {
                self.submissionState = .failed(self.mapToAppError(error))
            }
        }
    }

    private var composedBirthday: Date? {
        var components = DateComponents()
        components.day = birthDay
        components.month = birthMonth
        components.year = birthYear
        return Calendar.current.date(from: components)
    }
}
