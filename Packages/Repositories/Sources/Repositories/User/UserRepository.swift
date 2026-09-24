//
//  UserRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 18/9/26.
//

import CoreModels
import CoreNetworking
import Foundation

public final class UserRepository: UserRepositoryProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    public func fetchCurrentUser() async throws -> User {
        try await apiClient.request(UserEndpoint.fetchCurrentUser)
    }

    public func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        try await apiClient.request(UserEndpoint.updateProfile(request))
    }

    public func updateAccount(_ request: UpdateAccountRequest) async throws -> User {
        try await apiClient.request(UserEndpoint.updateAccount(request))
    }

    public func uploadAvatar(imageData: Data, fileName: String, mimeType: String) async throws -> User {
        try await apiClient.request(UploadAvatarEndpoint(imageData: imageData, fileName: fileName, mimeType: mimeType))
    }
}
