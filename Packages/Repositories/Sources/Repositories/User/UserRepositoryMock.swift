//
//  UserRepositoryMock.swift
//  Repositories
//
//  Created by Loi Nguyen on 18/9/26.
//

import CoreModels
import Foundation

public actor UserRepositoryMock: UserRepositoryProtocol {

    private var currentUser: User

    public init() {
        self.currentUser = User(
            id: "mock-user-1",
            username: "Frisk(Chara)",
            email: "friskchara@gmail.com",
            avatarURL: nil,
            bannerURL: nil,
            bio: "Hiiiiiiiiiiii ^^",
            birthday: Calendar.current.date(from: DateComponents(year: 2004, month: 2, day: 2)),
            gender: "Nam",
            address: "TP.HCM",
            interests: "Nghe nhạc - Gaming",
            joinedAt: Date(),
            isDarkMode: false,
            socialLinks: [
                "facebook": "https://www.facebook.com/tuyet.nguyen.213464",
                "discord": "https://discord.com/invite/FdFBy66S"
            ],
            role: .user
        )
    }

    public func fetchCurrentUser() async throws -> User {
        currentUser
    }

    public func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        if let bio = request.bio { currentUser.bio = bio }
        if let birthday = request.birthday { currentUser.birthday = birthday }
        if let gender = request.gender { currentUser.gender = gender }
        if let address = request.address { currentUser.address = address }
        if let interests = request.interests { currentUser.interests = interests }
        if let socialLinks = request.socialLinks { currentUser.socialLinks = socialLinks }
        return currentUser
    }

    public func updateAccount(_ request: UpdateAccountRequest) async throws -> User {
        currentUser.username = request.username
        currentUser.email = request.email
        return currentUser
    }
}
