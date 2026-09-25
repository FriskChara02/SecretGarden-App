//
//  PolicyView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 25/9/26.
//

// Pure static View — no ViewModel, no Repository. Renders a PolicyDocument
// (PolicyContent.swift) with the ornamental style used across Secret Garden

import SwiftUI

public struct PolicyView: View {
    private let document: PolicyDocument

    public init(document: PolicyDocument = PolicyContent.communityRules) {
        self.document = document
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                ornamentalHeader(text: document.displayTitle)

                VStack(spacing: DSSpacing.sm) {
                    Text(document.documentTitle)
                        .dsFont(.title1)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(DSColor.textPrimary)

                    Text(document.lastUpdatedLabel)
                        .dsFont(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColor.textSecondary)
                }

                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    ForEach(document.introParagraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .dsFont(.body)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(document.sections) { section in
                    sectionBlock(section)
                }

                ornamentalHeader(text: nil)
                    .padding(.top, DSSpacing.md)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.vertical, DSSpacing.xl)
        }
        .background(DSColor.backgroundPrimary)
        .navigationTitle(document.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Section block

    private func sectionBlock(_ section: PolicySection) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(section.heading)
                .dsFont(.headline)
                .fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)

            ForEach(section.bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: DSSpacing.xs) {
                    Circle()
                        .fill(DSColor.brandPrimary)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    Text(bullet)
                        .dsFont(.body)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Ornamental header/footer (◈ Regulations ◈ style)

    @ViewBuilder
    private func ornamentalHeader(text: String?) -> some View {
        HStack(spacing: DSSpacing.sm) {
            CornerFlourish(mirrored: false)
                .stroke(DSColor.brandPrimary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 40, height: 16)

            if let text {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(DSColor.brandPrimary)
                    Text(text)
                        .dsFont(.title2)
                        .foregroundStyle(DSColor.brandPrimary)
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(DSColor.brandPrimary)
                }
            }

            CornerFlourish(mirrored: true)
                .stroke(DSColor.brandPrimary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 40, height: 16)
        }
    }
}

/// Simple decorative curve used at each end of the ornamental header/footer.
private struct CornerFlourish: Shape {
    let mirrored: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if mirrored {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.width * 0.15, y: rect.height)
            )
        } else {
            path.move(to: CGPoint(x: rect.width, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.height),
                control: CGPoint(x: rect.width * 0.85, y: rect.height)
            )
        }
        return path
    }
}

#Preview {
    NavigationStack {
        PolicyView()
    }
}
