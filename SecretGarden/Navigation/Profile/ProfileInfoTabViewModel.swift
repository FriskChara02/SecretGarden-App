//
//  ProfileInfoTabViewModel.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 23/9/26.
//

import Combine
import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
final class ProfileInfoTabViewModel: BaseViewModel {

    private let userRepository: UserRepositoryProtocol

    @Published private(set) var isUploadingAvatar = false
    @Published var uploadErrorMessage: String?

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
        super.init()
    }

    func uploadAvatar(imageData: Data, fileName: String, mimeType: String, onUploaded: @escaping (User) -> Void) {
        isUploadingAvatar = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let updated = try await self.userRepository.uploadAvatar(
                    imageData: imageData,
                    fileName: fileName,
                    mimeType: mimeType
                )
                self.isUploadingAvatar = false
                onUploaded(updated)
            } catch {
                self.isUploadingAvatar = false
                self.uploadErrorMessage = self.mapToAppError(error).errorDescription
            }
        }
    }
}
