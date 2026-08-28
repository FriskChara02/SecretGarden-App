//
//  GardenFooterView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 27/8/26.
//

// Page footer — white block (logo + name + version + copyright) +
// pink gradient block (2 columns: Policies / Social Media).

import SwiftUI

public struct GardenFooterLink: Identifiable {
    public let id = UUID()
    public let title: String
    public let action: () -> Void
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

public struct GardenFooterView: View {
    private let appName: String
    private let tagline: String
    private let copyrightYear: String
    private let email: String
    private let policyLinks: [GardenFooterLink]
    private let socialLinks: [GardenFooterLink]
    private let onPolicyTapped: () -> Void

    public init(
        appName: String = "SECRET GARDEN",
        tagline: String = "Project Secret Garden Version 1.0",
        copyrightYear: String = "2026",
        email: String = "contact@secretgarden.app",               // TODO: change to real email
        policyLinks: [GardenFooterLink],
        socialLinks: [GardenFooterLink],
        onPolicyTapped: @escaping () -> Void
    ) {
        self.appName = appName
        self.tagline = tagline
        self.copyrightYear = copyrightYear
        self.email = email
        self.policyLinks = policyLinks
        self.socialLinks = socialLinks
        self.onPolicyTapped = onPolicyTapped
    }

    public var body: some View {
        VStack(spacing: 0) {
            topBlock
            bottomBlock
        }
    }

    private var topBlock: some View {
        VStack(spacing: DSSpacing.sm) {
            logoIcon

            Text(appName)
                .dsFont(.title2)
                .fontWeight(.bold)
                .foregroundStyle(DSColor.brandPrimary)
                .tracking(2)

            Text(tagline)
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)

            HStack(spacing: DSSpacing.xxs) {
                Text("© Copyright \(copyrightYear) \(appName) -")
                    .foregroundStyle(DSColor.textSecondary)
                Button(action: onPolicyTapped) {
                    Text("Chính sách").foregroundStyle(DSColor.brandPrimary).underline()
                }
            }
            .dsFont(.footnote)

            Text("Email: \(email)")
                .dsFont(.footnote)
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.vertical, DSSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(DSColor.backgroundPrimary)
    }

    @ViewBuilder
    private var logoIcon: some View {
        if let uiImage = UIImage(named: "AppLogo", in: .designSystemModule, compatibleWith: nil) {
            Image(uiImage: uiImage).resizable().scaledToFit().frame(width: 64, height: 64)
        } else {
            Image(systemName: "leaf.fill")
                .font(.system(size: 40))
                .foregroundStyle(DSColor.brandPrimary)
                .frame(width: 64, height: 64)
        }
    }

    private var bottomBlock: some View {
        ZStack(alignment: .top) {
            DiagonalRiseShape()
                .fill(
                    LinearGradient(
                        colors: [DSColor.brandPrimary.opacity(0.85), DSColor.brandPrimary],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            HStack(alignment: .top, spacing: DSSpacing.xl) {
                linkColumn(title: "\(appName) Chính Sách", links: policyLinks)
                linkColumn(title: "Mạng Xã Hội", links: socialLinks)
            }
            .padding(.top, 48) // avoid the diagonally cut section
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
        }
    }

    private func linkColumn(title: String, links: [GardenFooterLink]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title).dsFont(.headline).fontWeight(.bold).foregroundStyle(.white)
            ForEach(links) { link in
                Button(action: link.action) {
                    Text(link.title).dsFont(.subheadline).foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Top edge slanting UP (low on the left, high on the right)
private struct DiagonalRiseShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.14))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    GardenFooterView(
        policyLinks: [
            GardenFooterLink(title: "Chính sách bảo mật", action: {}),
            GardenFooterLink(title: "Quy định", action: {}),
            GardenFooterLink(title: "Điều khoản", action: {})
        ],
        socialLinks: [
            GardenFooterLink(title: "Discord", action: {}),
            GardenFooterLink(title: "Facebook", action: {})
        ],
        onPolicyTapped: {}
    )
}
