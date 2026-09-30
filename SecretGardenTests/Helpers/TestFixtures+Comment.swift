//
//  TestFixtures+Comment.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import CoreModels
import Foundation

extension TestFixtures {

    static func user(id: String = "u1", username: String = "frisk") -> User {
        User(id: id, username: username, email: "\(username)@example.com", joinedAt: Date())
    }

    static func comment(
        id: String = "cm1",
        content: String = "Hay quá!",
        likeCount: Int = 0,
        isLikedByMe: Bool = false,
        replies: [Comment]? = nil
    ) -> Comment {
        Comment(
            id: id,
            user: user(),
            content: content,
            likeCount: likeCount,
            isLikedByMe: isLikedByMe,
            createdAt: Date(),
            replies: replies
        )
    }
}
