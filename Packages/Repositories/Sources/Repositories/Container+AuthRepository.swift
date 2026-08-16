//
//  Container+AuthRepository.swift
//  Repositories
//
//  Created by Loi Nguyen on 16/8/26.
//

import FactoryKit

extension Container {
    public var authRepository: Factory<AuthRepositoryProtocol> {
        self { fatalError("authRepository must be registered in App target or Container setup") }
    }
}
