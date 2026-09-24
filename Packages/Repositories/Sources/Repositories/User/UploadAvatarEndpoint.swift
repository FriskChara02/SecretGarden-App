//
//  UploadAvatarEndpoint.swift
//  Repositories
//
//  Created by Loi Nguyen on 23/9/26.
//

import CoreNetworking
import Foundation

struct UploadAvatarEndpoint: APIEndpoint {

    private let boundary = "Boundary-\(UUID().uuidString)"
    private let imageData: Data
    private let fileName: String
    private let mimeType: String

    init(imageData: Data, fileName: String, mimeType: String) {
        self.imageData = imageData
        self.fileName = fileName
        self.mimeType = mimeType
    }

    var path: String { "/users/me/avatar" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { true }

    var headers: [String: String]? {
        ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }

    var body: Data? {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
}
