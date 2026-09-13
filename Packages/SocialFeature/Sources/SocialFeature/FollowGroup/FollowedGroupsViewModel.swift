//
//  FollowedGroupsViewModel.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class FollowedGroupsViewModel: BaseViewModel {

    private let groupRepository: GroupRepositoryProtocol

    @Published public private(set) var state: LoadableState<[TranslationGroup]> = .idle

    public init(groupRepository: GroupRepositoryProtocol) {
        self.groupRepository = groupRepository
        super.init()
    }

    public func onAppear() {
        load()
    }

    public func load() {
        state = .loading
        runTask({ [weak self] in
            guard let self else { return }
            let groups = try await self.groupRepository.fetchFollowedGroups()
            self.state = .loaded(groups)
        }, onError: { [weak self] error in
            self?.state = .failed(error)
        })
    }
}
