//
//  URLProtocolStub.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import Foundation

/// Intercept all URLSession requests using this configuration and return a simulated result.
final class URLProtocolStub: URLProtocol {

    struct Stub {
        var statusCode: Int = 200
        var data: Data = Data()
        var delay: TimeInterval = 0
        var error: Error?
    }

    private static let lock = NSLock()
    private static var handler: ((URLRequest) -> Stub)?
    private static var requests: [URLRequest] = []

    static var requestCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return requests.count
    }

    static func setHandler(_ newHandler: @escaping (URLRequest) -> Stub) {
        lock.lock()
        defer { lock.unlock() }
        handler = newHandler
        requests = []
    }

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        handler = nil
        requests = []
    }

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: config)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lock.lock()
        Self.requests.append(request)
        let currentHandler = Self.handler
        Self.lock.unlock()

        let stub = currentHandler?(request) ?? Stub(statusCode: 500)
        DispatchQueue.global().asyncAfter(deadline: .now() + stub.delay) { [weak self] in
            guard let self, let client = self.client else { return }
            if let error = stub.error {
                client.urlProtocol(self, didFailWithError: error)
                return
            }
            guard let url = self.request.url,
                  let response = HTTPURLResponse(
                    url: url, statusCode: stub.statusCode, httpVersion: nil, headerFields: nil
                  ) else { return }
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: stub.data)
            client.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
