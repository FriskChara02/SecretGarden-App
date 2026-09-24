//
//  UserRepositoryProtocol.swift
//  Repositories
//
//  Created by Loi Nguyen on 18/9/26.
//

import CoreModels
import Foundation

/// "Profile" domain - distinct from AuthRepositoryProtocol ("Auth: login/register/token" domain).
/// Any feature requiring read/write access to current user information depends solely on this protocol.
public protocol UserRepositoryProtocol: Sendable {

    /// GET /users/me
    func fetchCurrentUser() async throws -> User

    /// PUT /users/me
    func updateProfile(_ request: UpdateProfileRequest) async throws -> User

    /// PUT /users/me/account
    func updateAccount(_ request: UpdateAccountRequest) async throws -> User

    /// POST /users/me/avatar (multipart/form-data)
    func uploadAvatar(imageData: Data, fileName: String, mimeType: String) async throws -> User
}
