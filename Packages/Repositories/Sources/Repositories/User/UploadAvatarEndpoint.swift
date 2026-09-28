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
        func append(_ string: String) {
            guard let chunk = string.data(using: .utf8) else { return }
            data.append(chunk)
        }
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(fileName)\"\r\n")
        append("Content-Type: \(mimeType)\r\n\r\n")
        data.append(imageData)
        append("\r\n--\(boundary)--\r\n")
        return data
    }
}
