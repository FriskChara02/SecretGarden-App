//
//  GroupListCard.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

// Card displaying a group as a list item — shared by FollowedGroupsView and DiscoverGroupsView

import CoreModels
import DesignSystem
import SwiftUI

struct GroupListCard: View {
    let group: TranslationGroup
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                bannerAndAvatar
                content
            }
            .background(DSColor.backgroundPrimary)
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.lg).strokeBorder(DSColor.borderDefault, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        }
        .buttonStyle(.plain)
    }

    private var bannerAndAvatar: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [DSColor.brandPrimaryLight.opacity(0.35), DSColor.brandPrimary.opacity(0.5)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 90)

            avatarImage.offset(x: DSSpacing.md, y: 26)
        }
        .padding(.bottom, 26)
    }

    private var avatarImage: some View {
        DSCachedAsyncImage(url: group.avatarURL, resize: .size(CGSize(width: 60, height: 60))) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Circle().fill(DSColor.backgroundSecondary)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text(group.name).dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)

            HStack(spacing: DSSpacing.lg) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2").font(.caption2)
                    Text("\(group.followerCount) người theo dõi")
                }
                HStack(spacing: 4) {
                    Image(systemName: "calendar").font(.caption2)
                    Text(Self.dateFormatter.string(from: group.createdAt))
                }
            }
            .dsFont(.caption)
            .foregroundStyle(DSColor.textSecondary)

            if let description = group.description, !description.isEmpty {
                Text(description)
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
        .padding(DSSpacing.md)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"; return f
    }()
}
