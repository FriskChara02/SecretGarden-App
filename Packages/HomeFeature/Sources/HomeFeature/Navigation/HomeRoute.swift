//
//  HomeRoute.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import Foundation

/// Route for all navigation within the Home tab.
/// Used by the App target (Composition Root) to initialize `Coordinator<HomeRoute>`,
/// so the enum and all its cases must be `public`.
public enum HomeRoute: Hashable {
    case seriesDetail(id: String)
    case chapterReader(seriesId: String, chapterId: String)
}
