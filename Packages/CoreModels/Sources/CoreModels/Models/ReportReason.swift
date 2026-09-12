//
//  ReportReason.swift
//  CoreModels
//
//  Created by Loi Nguyen on 12/9/26.
//

// Reason for reporting a violation

import Foundation

public enum ReportReason: String, Codable, CaseIterable, Identifiable {
    case copyrightViolation
    case inappropriateContent
    case incorrectInformation
    case other

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .copyrightViolation: return "Nội dung vi phạm bản quyền"
        case .inappropriateContent: return "Nội dung không phù hợp"
        case .incorrectInformation: return "Thông tin truyện sai lệch"
        case .other: return "Khác"
        }
    }
}
