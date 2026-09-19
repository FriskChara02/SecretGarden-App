//
//  ProfileRoute.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// Temporarily placed in the App target — these cases will be moved to the appropriate Feature package.

import Foundation

enum ProfileRoute: Hashable {
    case personalInfo
    case editProfile
    case favorites
    case followedGroups
    case history
    case category
    case advancedSearch
    case yuriList
    case uploadRegistration
    case rules
    case seriesDetail(id: String)
    case chapterReader(seriesId: String, chapterId: String)
    case groupProfile(id: String)
    case authorProfile(id: String, roleLabel: String)
    case discoverGroups
    case login
}
